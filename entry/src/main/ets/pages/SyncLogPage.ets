import { TopBar, SectionTitle } from '../components/EraFilter'
import {
  CloudSyncService,
  SyncLogEntry,
  SyncLogResult,
  SyncConflict
} from '../services/CloudSyncService'
import { LocalStoreService } from '../services/LocalStoreService'

@Component
export struct SyncLogPage {
  @Link currentTab: number
  @Link routeRequest: string
  @State entries: SyncLogEntry[] = []
  @State totalConflicts: number = 0
  @State statusText: string = ''
  @State isLoading: boolean = false

  aboutToAppear(): void {
    this.load()
  }

  private pad(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }

  private formatTime(ms: number): string {
    if (ms <= 0) return '—'
    const d: Date = new Date(ms)
    return this.pad(d.getMonth() + 1) + '-' + this.pad(d.getDate())
      + ' ' + this.pad(d.getHours()) + ':' + this.pad(d.getMinutes()) + ':' + this.pad(d.getSeconds())
  }

  private fieldLabel(field: string): string {
    if (field === 'resourceId') return '关联条目'
    if (field === 'state') return '收藏状态'
    if (field === 'content') return '笔记正文'
    if (field === 'tags') return '标签'
    if (field === 'order') return '排序'
    if (field === 'createdAt') return '创建时间'
    if (field === 'updatedAt') return '修改时间'
    if (field === 'deleted') return '删除标记'
    if (field === 'name') return '主题名'
    if (field === 'color') return '颜色'
    if (field === 'description') return '主题描述'
    if (field === 'itemIds') return '包含条目'
    if (field === 'themeId') return '所属主题'
    if (field === 'itemId') return '关联条目'
    if (field === 'weight') return '关联强度'
    return field
  }

  private shortDevice(deviceId: string): string {
    if (deviceId.length <= 14) return deviceId
    return deviceId.substring(deviceId.length - 14)
  }

  private async load(): Promise<void> {
    if (this.isLoading) return
    this.isLoading = true
    try {
      const result: SyncLogResult = await CloudSyncService.log(LocalStoreService.accountKey(), 30)
      this.entries = result.entries
      let conflicts: number = 0
      for (let i = 0; i < this.entries.length; i++) {
        conflicts += this.entries[i].conflicts
      }
      this.totalConflicts = conflicts
      this.statusText = this.entries.length > 0
        ? '最近 ' + this.entries.length + ' 次同步，共 ' + conflicts + ' 处冲突'
        : '这个账号还没有同步记录'
    } catch (e) {
      this.statusText = '读取同步日志失败，检查网络后重试'
    } finally {
      this.isLoading = false
    }
  }

  @Builder
  ConflictRow(conflict: SyncConflict) {
    Column({ space: 3 }) {
      Text(this.fieldLabel(conflict.field))
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor('#243A38')
      Text(this.shortDevice(conflict.winnerDevice) + '  胜出，覆盖 ' + this.shortDevice(conflict.loserDevice))
        .fontSize(10)
        .fontColor('#347D73')
      Text('时间戳 ' + conflict.winnerAt.toString() + ' > ' + conflict.loserAt.toString())
        .fontSize(9)
        .fontColor('#818A87')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: 10, top: 7, bottom: 7 })
    .border({ width: { left: 2 }, color: '#347D73' })
  }

  @Builder
  EntryCard(entry: SyncLogEntry) {
    Column({ space: 9 }) {
      Row({ space: 8 }) {
        Column({ space: 3 }) {
          Text(entry.deviceId)
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C2C2A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.formatTime(entry.at))
            .fontSize(9)
            .fontColor('#818A87')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(entry.conflicts > 0 ? entry.conflicts.toString() + ' 冲突' : '无冲突')
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor(entry.conflicts > 0 ? '#B83A2D' : '#347D73')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(entry.conflicts > 0 ? '#FBEAE8' : '#E8F2EE')
          .borderRadius(9)
      }
      .width('100%')

      Row({ space: 12 }) {
        Text('上报 ' + entry.received.toString())
          .fontSize(9)
          .fontColor('#59645F')
        Text('应用 ' + entry.applied.toString())
          .fontSize(9)
          .fontColor('#59645F')
        Blank()
        Text('库内 ' + entry.stored.toString() + ' 项')
          .fontSize(9)
          .fontColor('#818A87')
      }
      .width('100%')

      if (entry.details.length > 0) {
        Column({ space: 6 }) {
          ForEach(entry.details, (conflict: SyncConflict) => {
            this.ConflictRow(conflict)
          }, (conflict: SyncConflict) => conflict.entityId + '#' + conflict.field)
        }
        .width('100%')
      }
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
          Text('同步日志')
            .fontSize(25)
            .fontFamily('serif')
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C2C2A')
          Text('每次同步的变更与冲突裁决，字段级最新写入优先')
            .fontSize(11)
            .fontColor('#78817E')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Row({ space: 12 }) {
          Column({ space: 3 }) {
            Text(this.entries.length.toString())
              .fontSize(19)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E3434')
            Text('同步次数')
              .fontSize(9)
              .fontColor('#7A8480')
          }
          .layoutWeight(1)
          Column({ space: 3 }) {
            Text(this.totalConflicts.toString())
              .fontSize(19)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.totalConflicts > 0 ? '#B83A2D' : '#1E3434')
            Text('冲突总数')
              .fontSize(9)
              .fontColor('#7A8480')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .backgroundColor('#FFFFFF')
        .borderRadius(14)
        .margin({ top: 10 })
        .border({ width: 1, color: '#E5E1D8' })

        if (this.statusText.length > 0) {
          Text(this.statusText)
            .fontSize(10)
            .fontColor('#6E7875')
            .width('100%')
            .margin({ top: 10 })
        }

        SectionTitle({ title: '同步记录', subtitle: '最新的在最上面' })

        if (this.entries.length === 0) {
          Text('还没有同步记录')
            .fontSize(11)
            .fontColor('#818A87')
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
        } else {
          Column({ space: 10 }) {
            ForEach(this.entries, (entry: SyncLogEntry) => {
              this.EntryCard(entry)
            }, (entry: SyncLogEntry) => entry.at.toString() + entry.deviceId)
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
