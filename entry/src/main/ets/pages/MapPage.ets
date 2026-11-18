import { webview } from '@kit.ArkWeb'
import { ARCHIVE_ITEMS } from '../data/ArchiveData'

// 地图 HTML 里点「当地遗址」时，通过这个桥把 id 传回 ArkUI，直接打开详情页
class MapDetailBridge {
  private opener: (id: string) => void = (id: string) => {}

  setOpener(opener: (id: string) => void): void {
    this.opener = opener
  }

  openArchiveDetail(id: string): void {
    this.opener(id)
  }
}

@Component
export struct MapPage {
  @Link selectedId: string
  private controller: webview.WebviewController = new webview.WebviewController()
  private bridge: MapDetailBridge = new MapDetailBridge()

  aboutToAppear(): void {
    this.bridge.setOpener((id: string) => {
      this.selectedId = id
    })
  }

  private injectArchiveData(): void {
    const payload: string = JSON.stringify(ARCHIVE_ITEMS).replace(/</g, '\\u003c')
    this.controller.runJavaScript('window.setArchiveData(' + payload + ')')
      .catch((error: Error) => console.error('[MapPage] archive inject failed', error.message))
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row() {
          Column({ space: 3 }) {
            Text('地址里的黄河记忆')
              .fontSize(20)
              .fontFamily('serif')
              .fontWeight(FontWeight.Bold)
              .fontColor('#1C2C2A')
            Text('点击地图上的圆点查看当地遗址档案')
              .fontSize(10)
              .fontColor('#78817E')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .height(54)
        .padding({ left: 16, right: 16 })

        Web({ src: $rawfile('henan_yellow_river_basin.html'), controller: this.controller })
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#00000000')
          .borderRadius(16)
          .border({ width: 1, color: '#E5E1D8' })
          .javaScriptProxy({
            object: this.bridge,
            name: 'archiveBridge',
            methodList: ['openArchiveDetail'],
            controller: this.controller
          })
          .onPageEnd(() => this.injectArchiveData())
          .onErrorReceive((event) => console.error('[MapPage] web error', JSON.stringify(event)))
          .onConsole((event) => {
            console.info('[MapWeb] ' + event.message.getMessage())
            return true
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 4, bottom: 78 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000000')
  }
}
