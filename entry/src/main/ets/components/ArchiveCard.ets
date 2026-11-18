import { ArchiveItem } from '../models/ArchiveModels'

let isShouJinFontRegistered: boolean = false

@Component
export struct ArchiveCard {
  @Prop item: ArchiveItem
  @Prop isFav: boolean = false
  onToggleFav?: (id: string) => void
  onCardClick?: (id: string) => void


  aboutToAppear(): void {
    if (isShouJinFontRegistered) return
    try {
      this.getUIContext().getFont().registerFont({
        familyName: 'ShouJinShu',
        familySrc: $rawfile('fonts/AaCuiZhuXianHeShouJinShu.ttf')
      })
      isShouJinFontRegistered = true
    } catch (error) {
      console.error('[ArchiveCard] shoujin font registration failed', JSON.stringify(error))
    }
  }

  private titleOutline(): ShadowOptions[] {
    let out: ShadowOptions[] = []
    let d: number = this.getUIContext().vp2px(0.55)
    let r: number = this.getUIContext().vp2px(0.18)
    for (let i = 0; i < 24; i++) {
      let a: number = Math.PI * 2 * i / 24
      out.push({
        radius: r,
        color: '#FFFFFF',
        offsetX: Math.cos(a) * d,
        offsetY: Math.sin(a) * d
      })
    }
    return out
  }

  @Builder cardImage(item: ArchiveItem) {
    if (item.id === 'yangshao') {
      Image($r("app.media.yangshao"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'erlitou') {
      Image($r("app.media.erlitou"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'shangcheng') {
      Image($r("app.media.shangcheng"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'yin') {
      Image($r("app.media.yin"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'longmen') {
      Image($r("app.media.longmen"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'baimasi') {
      Image($r("app.media.baimasi"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'zhouqiao') {
      Image($r("app.media.zhouqiao"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'tieta') {
      Image($r("app.media.tieta"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'miaodigou') {
      Image($r("app.media.miaodigou"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'yanshi-shang') {
      Image($r("app.media.yanshi_shang"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'dahecun') {
      Image($r("app.media.dahecun"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'hanwei-luoyang') {
      Image($r("app.media.hanwei_luoyang"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'gongyi-grotto') {
      Image($r("app.media.gongyi_grotto"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'songling') {
      Image($r("app.media.songling"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'xishuipo') {
      Image($r("app.media.xishuipo"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'huangye-kiln') {
      Image($r("app.media.huangye_kiln"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'qicheng') {
      Image($r("app.media.qicheng"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'dongzhou-wangcheng') {
      Image($r("app.media.dongzhou_wangcheng"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'suiyang-luoyang') {
      Image($r("app.media.suiyang_luoyang"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'youlicheng') {
      Image($r("app.media.youlicheng"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'hanjiaguan') {
      Image($r("app.media.hanjiaguan"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'jiahu') {
      Image($r("app.media.jiahu"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else if (item.id === 'huaiyang-pingliangtai') {
      Image($r("app.media.huaiyang_pingliangtai"))
        .width('100%')
        .height(130)
        .objectFit(ImageFit.Cover)
        .border({ width: 5, color: '#8B4513' })
        .borderRadius(12)
    } else {
      Blank()
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        this.cardImage(this.item)
        Column() {
          Text(this.item.era)
            .fontSize(10)
            .fontColor('#F6E7C6')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#99000000')
            .borderRadius(10)
            .margin({ left: 12, top: 12 })
          Blank()
          Text(this.item.title)
            .fontSize(21)
            .fontFamily('ShouJinShu')
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .textShadow(this.titleOutline())
            .margin({ left: 13, bottom: 13 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .height(130)
        .linearGradient({
          angle: 180,
          colors: [['#00000000', 0.0], ['#00000099', 1.0]]
        })

        Text(this.isFav ? '★' : '☆')
          .fontSize(23)
          .fontColor(this.isFav ? '#F0C96B' : '#FFFFFF')
          .width(38)
          .height(38)
          .textAlign(TextAlign.Center)
          .backgroundColor('#66000000')
          .borderRadius(19)
          .margin({ top: 10, right: 10 })
          .onClick(() => {
            if (this.onToggleFav) this.onToggleFav(this.item.id)
          })
      }
      .width('100%')

      Column({ space: 7 }) {
        Row() {
          Text(this.item.city + ' · ' + this.item.type)
            .fontSize(10)
            .fontColor('#B83A2D')
            .layoutWeight(1)
          Text(this.item.period)
            .fontSize(8)
            .fontColor('#8A918E')
        }
        .width('100%')

        Text(this.item.summary)
          .fontSize(11)
          .fontColor('#55615C')
          .maxLines(2)
          .lineHeight(17)
        Row({ space: 6 }) {
          ForEach(this.item.tags.slice(0, 2), (tag: string) => {
            Text(tag)
              .fontSize(9)
              .fontColor('#376A60')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#E7F1EC')
              .borderRadius(8)
          })
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(12)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .clip(true)
    .shadow({ radius: 12, color: '#14000000', offsetX: 0, offsetY: 5 })
    .onClick(() => {
      if (this.onCardClick) this.onCardClick(this.item.id)
    })
  }
}
