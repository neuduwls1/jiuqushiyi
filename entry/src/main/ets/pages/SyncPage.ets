import { TopBar, SectionTitle } from '../components/EraFilter'
import { SyncConfig } from '../services/SyncConfig'
import { LocalStoreService } from '../services/LocalStoreService'
import {
  CloudSyncService,
  SyncOutcome,
  SyncSnapshot,
  DevicePresence
} from '../services/CloudSyncService'
import { NoteRecord, SyncEntity } from '../models/ArchiveModels'

@Component
export struct SyncPage {
  @Link currentTab: number
  @Link syncProgress: number
  @Link conflictCount: number
  @Link routeRequest: string
  @Link @Watch('onAccountChanged') syncAccount: string

  @State backupDone: boolean = false
  @State accountMessage: string = '登录华为账号后，同一账号下的设备共享这一份文化记忆库'
  @State syncMessage: string = ''
  @State isSyncing: boolean = false
  @State remoteEntities: number = 0
  @State lastSyncLabel: string = '未同步'
  @State devices: DevicePresence[] = []
  @State deviceId: string = ''

  aboutToAppear(): void {
    try {
      LocalStoreService.init(getContext(this))
      SyncConfig.init(getContext(this))
      this.deviceId = LocalStoreService.ensureDeviceId()
      this.syncAccount = LocalStoreService.accountKey()
      CloudSyncService.configure(SyncConfig.baseUrl(), SyncConfig.token())
    } catch (e) {
      console.info('[SyncPage] state load deferred')
    }
    this.refresh()
  }

  onAccountChanged(): void {
    this.refresh()
  }

  private relative(ms: number): string {
    if (ms <= 0) return '未同步'
    const delta: number = Math.max(0, Date.now() - ms)
    const min: number = Math.floor(delta / 60000)
    if (min < 1) return '刚刚'
    if (min < 60) return min.toString() + ' 分钟前'
    return Math.floor(min / 60).toString() + ' 小时前'
  }

  private async refresh(): Promise<void> {
    try {
      const snapshot: SyncSnapshot = await CloudSyncService.pull(this.syncAccount)
      this.remoteEntities = snapshot.entityCount
      this.devices = snapshot.devices
      this.lastSyncLabel = this.relative(snapshot.updatedAt)
      if (this.syncMessage.length === 0) {
        this.syncMessage = snapshot.entityCount > 0
          ? '云端已有 ' + snapshot.entityCount + ' 个实体'
          : '这个账号在云端还没有数据'
      }
    } catch (e) {
      this.syncMessage = '连不上云端节点，检查网络后重试'
    }
  }

  private authorizeHuaweiDemo(): void {
    this.accountMessage = '演示模式：当前使用 demo-account，暂未切换华为账号'
  }

  private async syncNow(): Promise<void> {
    if (this.isSyncing) return
    this.isSyncing = true
    this.syncProgress = 30
    try {
      const deviceId: string = LocalStoreService.ensureDeviceId()
      const favorites: string[] = LocalStoreService.getFavorites()
      const notes: NoteRecord[] = LocalStoreService.getNotes()
      const entities: SyncEntity[] = CloudSyncService
        .favoriteEntities(favorites, deviceId, Date.now())
        .concat(CloudSyncService.noteEntities(notes, deviceId))
      const outcome: SyncOutcome = await CloudSyncService.push(this.syncAccount, deviceId, entities)
      this.syncProgress = 100
      this.conflictCount = outcome.stats.conflicts
      this.remoteEntities = outcome.entities.length
      this.syncMessage = outcome.message
      this.lastSyncLabel = '刚刚'
      await this.refresh()
    } catch (e) {
      this.syncProgress = 0
      this.syncMessage = '同步失败：检查网络或云端节点是否在运行'
    } finally {
      this.isSyncing = false
    }
  }

  private async restoreFromCloud(): Promise<void> {
    try {
      const snapshot: SyncSnapshot = await CloudSyncService.pull(this.syncAccount)
      const favorites: string[] = CloudSyncService.entitiesToFavorites(snapshot.entities)
      const notes: NoteRecord[] = CloudSyncService.entitiesToNotes(snapshot.entities)
      LocalStoreService.saveFavorites(favorites)
      LocalStoreService.saveNotes(notes)
      this.remoteEntities = snapshot.entityCount
      this.devices = snapshot.devices
      this.syncProgress = 100
      this.syncMessage = '已从云端恢复 ' + favorites.length + ' 条收藏、' + notes.length + ' 条笔记'
      this.lastSyncLabel = '刚刚'
    } catch (e) {
      this.syncMessage = '恢复失败：检查网络后重试'
    }
  }

  private async backupNow(): Promise<void> {
    try {
      const backupId: string = await CloudSyncService.backup(
        this.syncAccount,
        LocalStoreService.ensureDeviceId(),
        '手动备份'
      )
      this.backupDone = true
      this.syncMessage = '已创建云端快照 ' + backupId
    } catch (e) {
      this.syncMessage = '备份失败：检查网络后重试'
    }
  }

  @Builder
  SyncLog(glyph: string, title: string, detail: string, color: string) {
    Row({ space: 10 }) {
      Text(glyph)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .width(30)
        .height(30)
        .textAlign(TextAlign.Center)
        .backgroundColor(color)
        .borderRadius(15)
      Column({ space: 3 }) {
        Text(title)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#243A38')
        Text(detail)
          .fontSize(9)
          .fontColor('#7E8784')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
  }

  build() {
    Scroll() {
      Column() {
        TopBar({ currentTab: $currentTab })
        Column({ space: 12 }) {
          Row({ space: 12 }) {
            Text('本')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width(44)
              .height(44)
              .textAlign(TextAlign.Center)
              .backgroundColor('#818A87')
              .borderRadius(22)
            Column({ space: 4 }) {
              Text('未登录华为账号')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1E3434')
              Text('数据记在本机演示账号下')
                .fontSize(10)
                .fontColor('#59645F')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text('未授权')
              .fontSize(9)
              .fontWeight(FontWeight.Bold)
              .fontColor('#A86823')
              .padding({ left: 9, right: 9, top: 5, bottom: 5 })
              .backgroundColor('#F7EEDC')
              .borderRadius(10)
          }
          .width('100%')

          Column({ space: 6 }) {
            Row() {
              Text('本机设备')
                .fontSize(10)
                .fontColor('#818A87')
              Blank()
              Text(this.deviceId)
                .fontSize(10)
                .fontColor('#4A5450')
            }
            .width('100%')
            Row() {
              Text('云端节点')
                .fontSize(10)
                .fontColor('#818A87')
              Blank()
              Text('your-sync-server.example.com:8080')
                .fontSize(10)
                .fontColor('#4A5450')
            }
            .width('100%')
            Row() {
              Text('数据归属')
                .fontSize(10)
                .fontColor('#818A87')
              Blank()
              Text('demo-account')
                .fontSize(10)
                .fontColor('#4A5450')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
          }
          .width('100%')
          .padding(10)
          .backgroundColor('#FAF9F5')
          .borderRadius(10)

          Text(this.accountMessage)
            .fontSize(9)
            .fontColor('#6E7875')
            .lineHeight(15)
            .width('100%')

          Button('授权华为账号登录')
            .width('100%')
            .height(40)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('#C83D32')
            .onClick(() => {
              this.authorizeHuaweiDemo()
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .border({ width: 1, color: '#E5E1D8' })

        Column({ space: 14 }) {
          Row({ space: 8 }) {
            Column({ space: 4 }) {
              Text('本机')
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#244D6A')
              Text('手机')
                .fontSize(10)
                .fontColor('#59645F')
              Text(this.deviceId.length > 10 ? this.deviceId.substring(this.deviceId.length - 10) : this.deviceId)
                .fontSize(8)
                .fontColor('#818A87')
                .maxLines(1)
            }
            .layoutWeight(1)
            .height(96)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#E8F2EE')
            .borderRadius(14)

            Column({ space: 6 }) {
              Column({ space: 3 }) {
                Text('☁')
                  .fontSize(20)
                  .fontColor('#FFFFFF')
                Text('云端节点')
                  .fontSize(9)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
              .width(78)
              .height(58)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#315E78')
              .borderRadius(14)

              Text(this.remoteEntities.toString() + ' 个实体')
                .fontSize(9)
                .fontColor('#697370')
            }

            Column({ space: 4 }) {
              Text('其他设备')
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#244D6A')
              Text(this.devices.length.toString() + ' 台')
                .fontSize(10)
                .fontColor('#59645F')
              Text(this.devices.length > 0 ? '实时同步中' : '暂无其他设备')
                .fontSize(8)
                .fontColor('#818A87')
            }
            .layoutWeight(1)
            .height(96)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#E9EFF5')
            .borderRadius(14)
          }
          .width('100%')

          Progress({ value: this.syncProgress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .height(6)
            .color('#347D73')
            .backgroundColor('#E4E8E6')

          Row() {
            Column({ space: 4 }) {
              Text(this.lastSyncLabel)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1E3434')
              Text('最后同步')
                .fontSize(9)
                .fontColor('#818A87')
            }
            .layoutWeight(1)

            Column({ space: 4 }) {
              Text(this.remoteEntities.toString())
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1E3434')
              Text('云端实体')
                .fontSize(9)
                .fontColor('#818A87')
            }
            .layoutWeight(1)

            Column({ space: 4 }) {
              Text(this.conflictCount.toString())
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1E3434')
              Text('冲突记录')
                .fontSize(9)
                .fontColor('#818A87')
            }
            .layoutWeight(1)

            Column({ space: 4 }) {
              Text(this.devices.length.toString())
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1E3434')
              Text('在线设备')
                .fontSize(9)
                .fontColor('#818A87')
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 14, color: '#12000000', offsetX: 0, offsetY: 6 })

        Row({ space: 10 }) {
          Button(this.isSyncing ? '同步中…' : '立即同步')
            .layoutWeight(1)
            .height(44)
            .fontSize(12)
            .backgroundColor(this.isSyncing ? '#B9BDBB' : '#B83A2D')
            .enabled(!this.isSyncing)
            .onClick(() => {
              this.syncNow()
            })
          Button('云端恢复')
            .layoutWeight(1)
            .height(44)
            .fontSize(12)
            .backgroundColor('#315E78')
            .onClick(() => {
              this.restoreFromCloud()
            })
        }
        .width('100%')

        Text(this.syncMessage.length > 0 ? this.syncMessage : '尚未同步')
          .fontSize(10)
          .fontColor('#6E7875')
          .width('100%')

        SectionTitle({ title: '同步策略', subtitle: '最新时间戳优先，标签字段无损合并' })
        Column({ space: 12 }) {
              this.SyncLog('√', '云端同步节点', 'your-sync-server.example.com:8080 · 字段级 LWW', '#347D73')
          this.SyncLog('↻', '收藏变更自动上报', '点收藏即推送到账号，无需手动同步', '#315E78')
          this.SyncLog('⌁', '实时下行通道', '其他设备的改动会推回本机并自动合并', '#C18B36')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)

        Button(this.backupDone ? '备份已完成' : '备份个人文化记忆库')
          .width('100%')
          .height(46)
          .fontSize(12)
          .backgroundColor(this.backupDone ? '#347D73' : '#244D6A')
          .onClick(() => {
            this.backupNow()
          })

        Row({ space: 10 }) {
          Text('同步日志  →')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#347D73')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding({ top: 13, bottom: 13 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#E5E1D8' })
            .onClick(() => {
              this.routeRequest = 'synclog'
            })
          Text('备份与恢复  →')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#315E78')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding({ top: 13, bottom: 13 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#E5E1D8' })
            .onClick(() => {
              this.routeRequest = 'backup'
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 90 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
