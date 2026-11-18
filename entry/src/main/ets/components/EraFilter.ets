
@Component
export struct FilterChip {
  @Prop label: string
  @Prop selected: boolean = false
  onSelect?: () => void


  build() {
    Text(this.label)
      .fontSize(11)
      .fontWeight(this.selected ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.selected ? '#FFFFFF' : '#59645F')
      .padding({ left: 13, right: 13, top: 7, bottom: 7 })
      .backgroundColor(this.selected ? '#244D6A' : '#FFFFFF')
      .borderRadius(16)
      .border({ width: 1, color: this.selected ? '#244D6A' : '#D8D8D1' })
      .onClick(() => {
        if (this.onSelect) this.onSelect()
      })
  }
}

@Component
export struct SectionTitle {
  @Prop title: string
  @Prop subtitle: string
  onViewAll?: () => void


  build() {
    Row() {
      Column({ space: 3 }) {
        Text(this.title)
          .fontSize(20)
          .fontFamily('serif')
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C2C2A')
        Text(this.subtitle)
          .fontSize(10)
          .fontColor('#78817E')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      if (this.onViewAll) {
        Text('查看全部  →')
          .fontSize(10)
          .fontColor('#B83A2D')
          .padding({ left: 8, right: 4, top: 6, bottom: 6 })
          .onClick(() => {
            if (this.onViewAll) this.onViewAll()
          })
      }
    }
    .width('100%')
    .margin({ top: 8, bottom: 10 })
  }
}

@Component
export struct MetricBlock {
  @Prop value: string
  @Prop label: string


  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E3434')
      Text(this.label)
        .fontSize(9)
        .fontColor('#7A8480')
    }
    .layoutWeight(1)
    .height(70)
    .justifyContent(FlexAlign.Center)
  }
}

@Component
export struct TopBar {
  @Link currentTab: number


  build() {
    Row() {
      Column({ space: 2 }) {
        Text('九曲拾忆')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C2C2A')
          .fontFamily('serif')
        Text('河南段文化数字档案')
          .fontSize(10)
          .fontColor('#78817E')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Row({ space: 8 }) {
        // 同步入口：点一下跳到「同步」页配服务器地址
        Text('同步')
          .fontSize(9)
          .fontColor('#2F6B57')
          .height(38)
          .padding({ left: 11, right: 11 })
          .textAlign(TextAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(19)
          .onClick(() => {
            this.currentTab = 4
          })

        // 搜索：矢量图标（ic_search.svg），按整体墨迹几何居中
        Stack() {
          Image($r('app.media.ic_search'))
            .width(9.46)
            .height(9.46)
            .objectFit(ImageFit.Contain)
        }
        .width(38)
        .height(38)
        .backgroundColor('#FFFFFF')
        .borderRadius(19)
        .onClick(() => {
          this.currentTab = 1
        })
        Text('♡')
          .fontSize(18)
          .fontColor('#B83A2D')
          .width(38)
          .height(38)
          .textAlign(TextAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(19)
          .onClick(() => {
            this.currentTab = 3
          })
      }
    }
    .width('100%')
    .height(56)
  }
}
