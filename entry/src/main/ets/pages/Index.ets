import { HomePage } from './HomePage'
import { ArchivePage } from './ArchivePage'
import { DetailPage } from './DetailPage'
import { CollectionPage } from './CollectionPage'
import { SyncPage } from './SyncPage'
import { MapPage } from './MapPage'
import { KnowledgePage } from './KnowledgePage'
import { BackupPage } from './BackupPage'
import { SyncLogPage } from './SyncLogPage'
import { AIPage } from './AIPage'
import { BottomNavigation } from '../components/BottomNavigation'
import { LocalStoreService } from '../services/LocalStoreService'
import { CloudSyncService, SyncSnapshot } from '../services/CloudSyncService'
import { SyncConfig } from '../services/SyncConfig'
import { SyncEntity, NoteRecord } from '../models/ArchiveModels'

const ROUTE_DETAIL: string = 'detail'
const ROUTE_KNOWLEDGE: string = 'knowledge'
const ROUTE_BACKUP: string = 'backup'
const ROUTE_SYNC_LOG: string = 'synclog'

@Entry
@Component
struct Index {
  @State currentTab: number = 0
  @State selectedEra: string = '全部'
  @State selectedCity: string = '全部'
  @State @Watch('onSelectedIdChanged') selectedId: string = ''
  @State @Watch('onFavoritesChanged') favorites: string[] = ['erlitou', 'longmen', 'zhouqiao']
  @State @Watch('onRouteRequestChanged') routeRequest: string = ''
  @State @Watch('onSyncAccountChanged') syncAccount: string = 'demo-account'
  @State remoteNotesRev: number = 0
  @State syncProgress: number = 100
  @State conflictCount: number = 0
  // AI 对话页是否展开（全屏挂载，不走路由）
  @State aiOpen: boolean = false

  // 详情页走 Navigation 页面栈：列表页留在栈里不被销毁，返回时保持原滚动位置
  private pathStack: NavPathStack = new NavPathStack()

  // 收藏增量同步：记住上次同步过的收藏，只把变化推给云端，
  // 不整份重传，也不漏掉"取消收藏"这个动作。
  private syncedFavorites: string[] = []
  private pendingAdd: string[] = []
  private pendingRemove: string[] = []
  private isSyncingFavorites: boolean = false
  private watchReady: boolean = false
  private liveAccount: string = ''
  private liveOpen: boolean = false
  private catchUpRunning: boolean = false

  aboutToAppear(): void {
    try {
      let ctx = getContext(this)
      LocalStoreService.init(ctx)
      SyncConfig.init(ctx)
      CloudSyncService.configure(SyncConfig.baseUrl(), SyncConfig.token())
      let savedFavorites: string[] = LocalStoreService.getFavorites()
      if (savedFavorites.length > 0) {
        // 先对齐基线，避免启动时把已有的收藏当成"新增"重推一遍
        this.syncedFavorites = savedFavorites.slice()
        this.favorites = savedFavorites
      } else {
        LocalStoreService.saveFavorites(this.favorites)
        this.syncedFavorites = this.favorites.slice()
      }
      this.watchReady = true
    } catch (e) {
      console.info('[Index] LocalStore init deferred')
    }
    this.connectLive(this.syncAccount)
    // 换设备/首次安装时把账号里已有的数据并进来，否则新设备是空的
    this.catchUpFromCloud()
  }

  aboutToDisappear(): void {
    CloudSyncService.closeLive()
    this.liveOpen = false
  }

  onFavoritesChanged(): void {
    LocalStoreService.saveFavorites(this.favorites)
    if (!this.watchReady) return
    this.queueFavoriteDelta()
  }

  private accountKey(): string {
    return LocalStoreService.accountKey()
  }

  // 补拉一次账号数据。只并进来、不往回推：
  // 本地存储没保留字段级时间戳，贸然回推会用当前时间覆盖别的设备。
  // 冷启动、实时通道重连、以及从后台回到前台都会走这里。
  private async catchUpFromCloud(): Promise<void> {
    if (this.catchUpRunning) return
    this.catchUpRunning = true
    try {
      const snapshot: SyncSnapshot = await CloudSyncService.pull(this.syncAccount)
      if (snapshot.entityCount > 0) {
        this.applyRemoteMerge(snapshot.entities)
      }
    } catch (e) {
      console.info('[Index] catch-up deferred')
    } finally {
      this.catchUpRunning = false
    }
  }

  // 回到前台：确认实时通道还在，并补拉后台期间漏掉的变更
  onPageShow(): void {
    this.connectLive(this.syncAccount)
    this.catchUpFromCloud()
  }

  // ---- 实时通道：整个 App 只开一条，挂在根组件上 ----

  private connectLive(accountId: string): void {
    if (this.liveOpen && this.liveAccount === accountId) return
    CloudSyncService.closeLive()
    this.liveAccount = accountId
    this.liveOpen = true
    try {
      CloudSyncService.openLive(
        accountId,
        LocalStoreService.ensureDeviceId(),
        (event: string, payload: Object) => { this.onRemoteEvent(event, payload) },
        () => { this.catchUpFromCloud() }
      )
    } catch (e) {
      this.liveOpen = false
      console.info('[Index] live channel unavailable')
    }
  }

  onSyncAccountChanged(): void {
    // 'demo-account' 视为本地账号，不写进华为账号字段
    LocalStoreService.saveAccountId(this.syncAccount === 'demo-account' ? '' : this.syncAccount)
    this.connectLive(this.syncAccount)
    this.pullRemote()
  }

  private onRemoteEvent(event: string, payload: Object): void {
    if (event !== 'sync') return
    const data = payload as Record<string, Object>
    const from = data['deviceId']
    if (from && String(from) === LocalStoreService.getDeviceId()) {
      // 自己推上去的回声，不用再并一遍
      return
    }
    const raw = data['entities']
    if (!Array.isArray(raw)) return
    this.applyRemoteMerge(raw as SyncEntity[])
  }

  // 别人的改动并进来；先对齐基线，避免又被当成新变更推回服务器
  private applyRemoteMerge(entities: SyncEntity[]): void {
    const mergedFavorites: string[] = CloudSyncService.mergeFavorites(entities, this.favorites)
    if (!this.sameList(mergedFavorites, this.favorites)) {
      this.syncedFavorites = mergedFavorites.slice()
      this.favorites = mergedFavorites
    }
    const mergedNotes: NoteRecord[] = CloudSyncService.mergeNotes(entities, LocalStoreService.getNotes())
    LocalStoreService.saveNotes(mergedNotes)
    this.remoteNotesRev = this.remoteNotesRev + 1
  }

  // 切换账号时用覆盖而不是合并，否则换到空账号会看不出差别
  private async pullRemote(): Promise<void> {
    try {
      const snapshot: SyncSnapshot = await CloudSyncService.pull(this.syncAccount)
      const favorites: string[] = CloudSyncService.entitiesToFavorites(snapshot.entities)
      const notes: NoteRecord[] = CloudSyncService.entitiesToNotes(snapshot.entities)
      this.syncedFavorites = favorites.slice()
      this.favorites = favorites
      LocalStoreService.saveNotes(notes)
      this.remoteNotesRev = this.remoteNotesRev + 1
    } catch (e) {
      console.info('[Index] account switch pull deferred')
    }
  }

  private sameList(a: string[], b: string[]): boolean {
    if (a.length !== b.length) return false
    for (let i = 0; i < a.length; i++) {
      if (a[i] !== b[i]) return false
    }
    return true
  }

  private queueFavoriteDelta(): void {
    const current: string[] = this.favorites

    for (let i = 0; i < current.length; i++) {
      const id: string = current[i]
      if (this.syncedFavorites.indexOf(id) < 0) {
        this.pendingAdd.push(id)
        const hit: number = this.pendingRemove.indexOf(id)
        if (hit >= 0) this.pendingRemove.splice(hit, 1)
      }
    }
    for (let i = 0; i < this.syncedFavorites.length; i++) {
      const id: string = this.syncedFavorites[i]
      if (current.indexOf(id) < 0) {
        this.pendingRemove.push(id)
        const hit: number = this.pendingAdd.indexOf(id)
        if (hit >= 0) this.pendingAdd.splice(hit, 1)
      }
    }

    this.syncedFavorites = current.slice()
    this.flushFavorites()
  }

  private async flushFavorites(): Promise<void> {
    if (this.isSyncingFavorites) return
    if (this.pendingAdd.length === 0 && this.pendingRemove.length === 0) return
    this.isSyncingFavorites = true

    const adds: string[] = this.pendingAdd.slice()
    const removes: string[] = this.pendingRemove.slice()
    this.pendingAdd = []
    this.pendingRemove = []

    try {
      const deviceId: string = LocalStoreService.ensureDeviceId()
      const now: number = Date.now()
      const entities: SyncEntity[] = []
      for (let i = 0; i < adds.length; i++) {
        entities.push(CloudSyncService.favoriteEntity(adds[i], true, deviceId, now))
      }
      for (let i = 0; i < removes.length; i++) {
        entities.push(CloudSyncService.favoriteEntity(removes[i], false, deviceId, now))
      }
      await CloudSyncService.push(this.accountKey(), deviceId, entities)
      console.info('[Index] favorites synced +' + adds.length + ' -' + removes.length)
    } catch (e) {
      // 失败就塞回队列，下一次收藏变更或手动同步会再试
      this.pendingAdd = adds.concat(this.pendingAdd)
      this.pendingRemove = removes.concat(this.pendingRemove)
      console.info('[Index] favorite sync deferred')
    } finally {
      this.isSyncingFavorites = false
      if (this.pendingAdd.length > 0 || this.pendingRemove.length > 0) {
        this.flushFavorites()
      }
    }
  }

  private topRoute(): string {
    let names: string[] = this.pathStack.getAllPathName()
    return names.length > 0 ? names[names.length - 1] : ''
  }

  private pushRoute(name: string): void {
    // 同名路由已经压在栈顶时，先弹掉再压入：
    // 否则第二次点击会被“已在栈顶”挡掉，表现为“只能点进去一次”
    if (this.topRoute() === name) {
      this.pathStack.pop()
    }
    this.pathStack.pushPathByName(name, null)
  }

  private popRoute(name: string): void {
    if (this.topRoute() === name) {
      this.pathStack.pop()
    }
  }

  onSelectedIdChanged(): void {
    if (this.selectedId.length > 0) {
      this.pushRoute(ROUTE_DETAIL)
    } else {
      this.popRoute(ROUTE_DETAIL)
    }
  }

  // 子页面通过把 routeRequest 置成路由名来请求跳转，清空则返回。
  // 走状态而不是直接拿 pathStack，和 selectedId 开详情页是同一套写法。
  onRouteRequestChanged(): void {
    if (this.routeRequest.length > 0) {
      this.pushRoute(this.routeRequest)
      return
    }
    const top: string = this.topRoute()
    if (top === ROUTE_KNOWLEDGE || top === ROUTE_BACKUP || top === ROUTE_SYNC_LOG) {
      this.pathStack.pop()
    }
  }

  @Builder
  PageMap(name: string) {
    if (name === ROUTE_DETAIL) {
      NavDestination() {
        DetailPage({ selectedId: $selectedId, favorites: $favorites })
      }
      .hideTitleBar(true)
      .backgroundColor('#00000000')
      .onHidden(() => {
        // 手势返回/系统返回时同步状态，避免下次点同一张卡片不跳转
        if (this.selectedId.length > 0) {
          this.selectedId = ''
        }
      })
    }
    if (name === ROUTE_KNOWLEDGE) {
      NavDestination() {
        KnowledgePage({ currentTab: $currentTab, routeRequest: $routeRequest })
      }
      .hideTitleBar(true)
      .backgroundColor('#00000000')
      .onHidden(() => {
        if (this.routeRequest.length > 0) {
          this.routeRequest = ''
        }
      })
    }
    if (name === ROUTE_BACKUP) {
      NavDestination() {
        BackupPage({ currentTab: $currentTab, routeRequest: $routeRequest })
      }
      .hideTitleBar(true)
      .backgroundColor('#00000000')
      .onHidden(() => {
        if (this.routeRequest.length > 0) {
          this.routeRequest = ''
        }
      })
    }
    if (name === ROUTE_SYNC_LOG) {
      NavDestination() {
        SyncLogPage({ currentTab: $currentTab, routeRequest: $routeRequest })
      }
      .hideTitleBar(true)
      .backgroundColor('#00000000')
      .onHidden(() => {
        if (this.routeRequest.length > 0) {
          this.routeRequest = ''
        }
      })
    }
  }

  @Builder
  MainContent() {
    Column() {
      if (this.currentTab === 0) {
        HomePage({
          currentTab: $currentTab,
          selectedEra: $selectedEra,
          favorites: $favorites,
          selectedId: $selectedId
        })
      } else if (this.currentTab === 1) {
        ArchivePage({
          currentTab: $currentTab,
          selectedEra: $selectedEra,
          selectedCity: $selectedCity,
          favorites: $favorites,
          selectedId: $selectedId
        })
      } else if (this.currentTab === 2) {
        MapPage({ selectedId: $selectedId })
      } else if (this.currentTab === 3) {
        CollectionPage({
          currentTab: $currentTab,
          favorites: $favorites,
          selectedId: $selectedId,
          routeRequest: $routeRequest,
          remoteNotesRev: $remoteNotesRev,
          aiOpen: $aiOpen
        })
      } else {
        SyncPage({
          currentTab: $currentTab,
          syncProgress: $syncProgress,
          conflictCount: $conflictCount,
          routeRequest: $routeRequest,
          syncAccount: $syncAccount
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  // 系统返回：AI 页打开时先关 AI，而不是直接退出应用
  onBackPress(): boolean {
    if (this.aiOpen) {
      this.aiOpen = false
      return true
    }
    return false
  }

  build() {
    Stack() {
      Navigation(this.pathStack) {
        Stack({ alignContent: Alignment.Top }) {
          Image($r('app.media.xuan_paper_07_light'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .interpolation(ImageInterpolation.High)

          Stack({ alignContent: Alignment.Bottom }) {
            this.MainContent()
            BottomNavigation({ currentTab: $currentTab })
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F7F4ED')
      }
      .mode(NavigationMode.Stack)
      .hideTitleBar(true)
      .navDestination(this.PageMap)
      .width('100%')
      .height('100%')
      .backgroundColor('#F7F4ED')

      // AI 对话页：整页挂载在 Navigation 之上，不走路由栈，
      // 点一次开一次、关闭即销毁，规避 NavDestination 里高度塌陷导致的白屏。
      if (this.aiOpen) {
        AIPage({
          onClose: () => {
            this.aiOpen = false
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F4ED')
  }
}
