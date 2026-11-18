import { ArchiveItem } from '../models/ArchiveModels'
import { ARCHIVE_ITEMS } from '../data/ArchiveData'
import { TopBar, FilterChip, SectionTitle, MetricBlock } from '../components/EraFilter'
import { ArchiveCard } from '../components/ArchiveCard'

let isCalligraphyFontRegistered: boolean = false

@Component
export struct HomePage {
  @Link currentTab: number
  @Link selectedEra: string
  @Link favorites: string[]
  @Link selectedId: string

  private eras: string[] = ['全部', '夏以前', '夏商', '周', '汉唐', '宋', '南北朝']


  aboutToAppear(): void {
    if (isCalligraphyFontRegistered) return
    try {
      this.getUIContext().getFont().registerFont({
        familyName: 'ZhiMangXing',
        familySrc: $rawfile('fonts/ZhiMangXing-Regular.ttf')
      })
      isCalligraphyFontRegistered = true
    } catch (error) {
      console.error('[HomePage] calligraphy font registration failed', JSON.stringify(error))
    }
  }

  private isFavorite(id: string): boolean {
    return this.favorites.indexOf(id) >= 0
  }

  private toggleFavorite(id: string): void {
    if (this.isFavorite(id)) {
      this.favorites = this.favorites.filter((v: string) => v !== id)
    } else {
      this.favorites = [id].concat(this.favorites)
    }
  }

  build() {
    Scroll() {
      Column({ space: 13 }) {
        TopBar({ currentTab: $currentTab })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_huanghe'))
            .width('100%')
            .height(230)
            .objectFit(ImageFit.Cover)
            .interpolation(ImageInterpolation.High)

          Column() {
            Text('HENAN · 5000 YEARS')
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor('#9C4A2E')
              .letterSpacing(2)
            Text('黄河，\n六千年的回声')
              .fontSize(32)
              .fontFamily('ZhiMangXing')
              .fontWeight(FontWeight.Normal)
              .fontColor('#2E2419')
              .margin({ top: 10 })
            Text('从仰韶彩陶，到东京梦华。')
              .fontSize(12)
              .fontColor('#6A5744')
              .margin({ top: 10 })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(20)
        }
        .width('100%')
        .height(230)
        .borderRadius(18)
        .clip(true)
        .onClick(() => { this.currentTab = 1 })

        Row() {
          MetricBlock({ value: ARCHIVE_ITEMS.length.toString(), label: '文化档案' })
          MetricBlock({ value: '6', label: '历史朝代' })
          MetricBlock({ value: '100%', label: '离线可读' })
        }
        .width('100%')
        .margin({ top: 14 })
        .backgroundColor('#FFFFFF')
        .borderRadius(14)

        SectionTitle({
          title: '沿朝代阅读',
          subtitle: '选择朝代进入文化序列',
          onViewAll: () => {
            this.selectedEra = '全部'
            this.currentTab = 1
          }
        })
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.eras, (era: string) => {
              FilterChip({
                label: era,
                selected: this.selectedEra === era,
                onSelect: () => { this.selectedEra = era }
              })
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        SectionTitle({
          title: '为你续写文化脉络',
          subtitle: '根据收藏与浏览行为离线计算',
          onViewAll: () => {
            this.selectedEra = '全部'
            this.currentTab = 1
          }
        })
        ForEach(ARCHIVE_ITEMS.slice(1, 4), (item: ArchiveItem) => {
          ArchiveCard({
            item: item,
            isFav: this.isFavorite(item.id),
            onToggleFav: (id: string) => { this.toggleFavorite(id) },
            onCardClick: (id: string) => { this.selectedId = id }
          })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 90 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
