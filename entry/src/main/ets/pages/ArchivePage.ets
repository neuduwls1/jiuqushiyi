import { ArchiveItem } from '../models/ArchiveModels'
import { ARCHIVE_ITEMS } from '../data/ArchiveData'
import { TopBar, FilterChip, SectionTitle } from '../components/EraFilter'
import { ArchiveCard } from '../components/ArchiveCard'

let isShouJinFontRegistered: boolean = false

@Component
export struct ArchivePage {
  @Link currentTab: number
  @Link selectedEra: string
  @Link selectedCity: string
  @Link favorites: string[]
  @Link selectedId: string
  @State query: string = ''
  @State selectedType: string = '全部'

  private cities: string[] = ['全部', '三门峡', '洛阳', '郑州', '开封', '濮阳', '安阳', '漯河', '周口']
  private types: string[] = ['全部', '都城遗址', '墓葬群', '窑址', '古建筑']
  private eras: string[] = ['全部', '夏以前', '夏商', '周', '汉唐', '宋', '南北朝']


  aboutToAppear(): void {
    if (isShouJinFontRegistered) return
    try {
      this.getUIContext().getFont().registerFont({
        familyName: 'ShouJinShu',
        familySrc: $rawfile('fonts/AaCuiZhuXianHeShouJinShu.ttf')
      })
      isShouJinFontRegistered = true
    } catch (error) {
      console.error('[ArchivePage] shoujin font registration failed', JSON.stringify(error))
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

  private matchesType(item: ArchiveItem): boolean {
    if (this.selectedType === '全部') return true
    if (this.selectedType === '都城遗址') {
      return item.type === '都城遗址' || item.type === '古城遗址' || item.type === '城址' ||
        item.type === '城市遗址'
    }
    if (this.selectedType === '墓葬群') {
      return item.type === '墓葬群' || item.type === '帝王陵墓'
    }
    if (this.selectedType === '窑址') {
      return item.type === '窑址' || item.type === '陶瓷窑址'
    }
    if (this.selectedType === '古建筑') {
      return item.type === '古建筑' || item.type === '佛教寺院' || item.type === '石窟寺' ||
        item.type === '石刻艺术' || item.type === '水利遗址' || item.type === '关隘遗址'
    }
    return false
  }

  private matchesQuery(item: ArchiveItem): boolean {
    let query: string = this.query.trim().toLowerCase()
    if (query.length === 0) return true
    let fields: string[] = [
      item.title,
      item.summary,
      item.city,
      item.era,
      item.type,
      item.period,
      item.travel
    ].concat(item.tags).concat(item.discoveries).concat(item.poems)
    for (let i = 0; i < fields.length; i++) {
      if (fields[i].toLowerCase().indexOf(query) >= 0) {
        return true
      }
    }
    return false
  }

  private filteredItems(): ArchiveItem[] {
    return ARCHIVE_ITEMS.filter((item: ArchiveItem) => {
      let eraMatched: boolean = this.selectedEra === '全部' || item.era === this.selectedEra
      let cityMatched: boolean = this.selectedCity === '全部' || item.city === this.selectedCity
      return eraMatched && cityMatched && this.matchesType(item) && this.matchesQuery(item)
    })
  }

  @Builder
  FilterLabel(label: string) {
    Text(label)
      .width(52)
      .fontSize(23.4)
      .fontFamily('ShouJinShu')
      .fontColor('#6B4D35')
  }

  build() {
    Column() {
      Column() {
        TopBar({ currentTab: $currentTab })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      Column({ space: 12 }) {
        Column({ space: 4 }) {
          Text('黄河文化数字档案')
            .fontSize(24)
            .fontFamily('serif')
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C2C2A')
          Text('按朝代、城市与类型检索遗址和文物')
            .fontSize(11)
            .fontColor('#78817E')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        TextInput({ placeholder: '搜索遗址、文物或关键词', text: this.query })
          .height(44)
          .fontSize(12)
          .placeholderColor('#9A9F9C')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => { this.query = value })

        Row({ space: 8 }) {
          this.FilterLabel('城市')
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.cities, (city: string) => {
                FilterChip({
                  label: city,
                  selected: this.selectedCity === city,
                  onSelect: () => { this.selectedCity = city }
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
        .width('100%')

        Row({ space: 8 }) {
          this.FilterLabel('类型')
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.types, (type: string) => {
                FilterChip({
                  label: type,
                  selected: this.selectedType === type,
                  onSelect: () => { this.selectedType = type }
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 8 })

        Row({ space: 8 }) {
          this.FilterLabel('朝代')
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
          .layoutWeight(1)
        }
        .width('100%')

        Row() {
          Text('共找到 ' + this.filteredItems().length + ' 条档案')
            .fontSize(11)
            .fontColor('#697370')
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 12 })

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.filteredItems(), (item: ArchiveItem) => {
            ArchiveCard({
              item: item,
              isFav: this.isFavorite(item.id),
              onToggleFav: (id: string) => { this.toggleFavorite(id) },
              onCardClick: (id: string) => { this.selectedId = id }
            })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 90 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
