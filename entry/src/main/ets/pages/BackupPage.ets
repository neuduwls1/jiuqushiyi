import { TopBar, SectionTitle } from '../components/EraFilter'
import {
  CloudSyncService,
  BackupSummary,
  BackupList,
  RestoreResult,
  SyncSnapshot
} from '../services/CloudSyncService'
import { LocalStoreService } from '../services/LocalStoreService'
import { NoteRecord } from '../models/ArchiveModels'

// 分布式备份与恢复：云端时间点快照 + 一键回灌本机。

@Component
export struct BackupPage {
  @Link currentTab: number
  @Link routeRequest: string
  @State backups: BackupSummary[] = []
  @State statusText: string = ''
  @State isLoading: boolean = false
  @State isCreating: boolean = false
  @State restoringId: string = ''

  aboutToAppear(): void {
    this.load()
  }

  private accountKey(): string {
    let accountId: string = ''
    try {
      LocalStoreService.init(getContext(this))
      accountId = LocalStoreService.getAccountId()
    } catch (e) {
      console.info('[BackupPage] account lookup deferred')
    }
    return accountId.length > 0 ? accountId : 'demo-account'
  }

  private pad(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }

  private formatTime(ms: number): string {
    if (ms <= 0) return '—'
    const d: Date = new Date(ms)
    return d.getFullYear().toString() + '-' + this.pad(d.getMonth() + 1) + '-' + this.pad(d.getDate())
      + ' ' + this.pad(d.getHours()) + ':' + this.pad(d.getMinutes())
  }

  private async load(): Promise<void> {
    if (this.isLoading) return
    this.isLoading = true
    try {
      const result: BackupList = await CloudSyncService.listBackups(this.accountKey())
      this.backups = result.backups
      if (this.statusText.length === 0) {
        this.statusText = this.backups.length > 0
          ? '云端共有 ' + this.backups.length + ' 个快照'
          : '还没有快照，点下面的按钮创建第一个'
      }
    } catch (e) {
      this.statusText = '读取快照失败：' + JSON.stringify(e)
    } finally {
      this.isLoading = false
    }
  }

  private async createBackup(): Promise<void> {
    if (this.isCreating) return
    this.isCreating = true
    try {
      const deviceId: string = LocalStoreService.ensureDeviceId()
      const backupId: string = await CloudSyncService.backup(this.accountKey(), deviceId, '手动备份')
      this.statusText = '已创建快照 ' + backupId
      await this.load()
    } catch (e) {
      this.statusText = '创建快照失败：' + JSON.stringify(e)
    } finally {
      this.isCreating = false
    }
  }

  // 恢复 = 服务端回到快照 + 本机立刻回灌，一步到位
  private async restore(backupId: string): Promise<void> {
    if (this.restoringId.length > 0) return
    this.restoringId = backupId
    try {
      const accountId: string = this.accountKey()
      const result: RestoreResult = await CloudSyncService.restore(accountId, backupId)
      const snapshot: SyncSnapshot = await CloudSyncService.pull(accountId)
      const favorites: string[] = CloudSyncService.entitiesToFavorites(snapshot.entities)
      const notes: NoteRecord[] = CloudSyncService.entitiesToNotes(snapshot.entities)
      LocalStoreService.saveFavorites(favorites)
      LocalStoreService.saveNotes(notes)
      this.statusText = '已恢复 ' + result.restoredEntities + ' 个实体：'
        + favorites.length + ' 条收藏、' + notes.length + ' 条笔记'
    } catch (e) {
      this.statusText = '恢复失败：' + JSON.stringify(e)
    } finally {
      this.restoringId = ''
    }
  }

  @Builder
  BackupRow(item: BackupSummary) {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Column({ space: 3 }) {
          Text(item.label.length > 0 ? item.label : '快照 ' + item.backupId)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C2C2A')
          Text(this.formatTime(item.createdAt))
            .fontSize(9)
            .fontColor('#818A87')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button(this.restoringId === item.backupId ? '恢复中…' : '恢复')
          .height(32)
          .fontSize(11)
          .backgroundColor(this.restoringId.length > 0 ? '#B9BDBB' : '#315E78')
          .enabled(this.restoringId.length === 0)
          .onClick(() => {
            this.restore(item.backupId)
          })
      }
      .width('100%')

      Row({ space: 12 }) {
        Text('收藏 ' + item.counts.favorite.toString())
          .fontSize(9)
          .fontColor('#59645F')
        Text('笔记 ' + item.counts.note.toString())
          .fontSize(9)
          .fontColor('#59645F')
        Text('主题 ' + item.counts.theme.toString())
          .fontSize(9)
          .fontColor('#59645F')
        Text('关联 ' + item.counts.relation.toString())
          .fontSize(9)
          .fontColor('#59645F')
        Blank()
        Text('共 ' + item.entityCount.toString() + ' 项')
          .fontSize(9)
          .fontColor('#818A87')
      }
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(13)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#E5E1D8' })
  }

  build() {
    Scroll() {
      Column() {
        TopBar({ currentTab: $currentTab })

        Row() {
          Text('‹ 返回')
            .fontSize(12)
            .fontColor('#315E78')
            .padding({ right: 12, top: 4, bottom: 4 })
            .onClick(() => {
              this.routeRequest = ''
            })
          Blank()
          Text(this.isLoading ? '读取中…' : '刷新')
            .fontSize(12)
            .fontColor('#B83A2D')
            .padding({ left: 12, top: 4, bottom: 4 })
            .onClick(() => {
              this.load()
            })
        }
        .width('100%')

        Column({ space: 5 }) {
          Text('分布式备份与恢复')
            .fontSize(25)
            .fontFamily('serif')
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C2C2A')
          Text('收藏、笔记、主题与知识关联的云端时间点快照')
            .fontSize(11)
            .fontColor('#78817E')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Button(this.isCreating ? '正在创建…' : '创建云端快照')
          .width('100%')
          .height(46)
          .fontSize(12)
          .backgroundColor(this.isCreating ? '#B9BDBB' : '#244D6A')
          .enabled(!this.isCreating)
          .margin({ top: 12 })
          .onClick(() => {
            this.createBackup()
          })

        if (this.statusText.length > 0) {
          Text(this.statusText)
            .fontSize(10)
            .fontColor('#6E7875')
            .width('100%')
            .margin({ top: 10 })
        }

        SectionTitle({ title: '历史快照', subtitle: '服务端每天自动存一份，最多保留 30 份' })

        if (this.backups.length === 0) {
          Text('暂无快照')
            .fontSize(11)
            .fontColor('#818A87')
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
        } else {
          Column({ space: 10 }) {
            ForEach(this.backups, (item: BackupSummary) => {
              this.BackupRow(item)
            })
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 90 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
