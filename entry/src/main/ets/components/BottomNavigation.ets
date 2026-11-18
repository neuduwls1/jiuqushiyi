@Component
export struct BottomNavigation {
  @Link currentTab: number

  private iconRes(index: number, active: boolean): Resource {
    if (index === 0) return active ? $r('app.media.nav_home_active') : $r('app.media.nav_home')
    if (index === 1) return active ? $r('app.media.nav_archive_active') : $r('app.media.nav_archive')
    if (index === 2) return active ? $r('app.media.nav_map_active') : $r('app.media.nav_map')
    if (index === 3) return active ? $r('app.media.nav_favorite_active') : $r('app.media.nav_favorite')
    return active ? $r('app.media.nav_sync_active') : $r('app.media.nav_sync')
  }

  @Builder
  BottomTab(index: number, label: string) {
    Column({ space: 4 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image(this.iconRes(index, this.currentTab === index))
          .width(20)
          .height(20)
      }
      .width(36)
      .height(36)
      .backgroundColor(this.currentTab === index ? '#B83A2D' : '#FFFDF8')
      .borderRadius(13)
      .border({
        width: this.currentTab === index ? 1.5 : 1,
        color: this.currentTab === index ? '#A42F25' : '#E0D7C9'
      })
      .shadow({
        radius: this.currentTab === index ? 6 : 4,
        color: this.currentTab === index ? '#2BB83A2D' : '#1F5B4E39',
        offsetX: 0,
        offsetY: 2
      })

      Text(label)
        .fontSize(9)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTab === index ? '#B83A2D' : '#7E8884')
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTab = index
    })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.xuan_paper_07_light'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.82)

      Row() {
        this.BottomTab(0, '首页')
        this.BottomTab(1, '档案')
        this.BottomTab(2, '地图')
        this.BottomTab(3, '收藏')
        this.BottomTab(4, '同步')
      }
      .width('100%')
      .height('100%')
      .padding({ left: 8, right: 8, top: 6, bottom: 6 })
    }
    .width('100%')
    .height(72)
    .backgroundColor('#FCFAF5')
    .border({ width: { top: 1 }, color: '#D8CDBF' })
  }
}
