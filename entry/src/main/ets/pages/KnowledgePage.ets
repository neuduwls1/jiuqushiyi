import { TopBar, SectionTitle } from '../components/EraFilter'
import {
  CloudSyncService,
  KnowledgeGraph,
  GraphNode,
  GraphEdge,
  RecommendResult,
  Recommendation
} from '../services/CloudSyncService'
import { LocalStoreService } from '../services/LocalStoreService'
import { display } from '@kit.ArkUI'

@Component
export struct KnowledgePage {
  @Link currentTab: number
  @Link routeRequest: string
  @State nodes: GraphNode[] = []
  @State edges: GraphEdge[] = []
  @State themeCount: number = 0
  @State itemCount: number = 0
  @State savedCount: number = 0
  @State recommendations: Recommendation[] = []
  @State statusText: string = '正在加载知识图谱…'
  @State isLoading: boolean = false

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  // 画布坐标是 vp，但 ctx.font 里的 px 是物理像素，两者差一个屏幕密度。
  // 不乘这个系数，3 倍屏上的 12px 实际只有 4vp，小到看不清。
  private density: number = 3

  aboutToAppear(): void {
    try {
      this.density = display.getDefaultDisplaySync().densityPixels
    } catch (e) {
      console.info('[KnowledgePage] density lookup failed, assuming 3')
    }
    this.load()
  }

  private font(sizeVp: number, bold: boolean): string {
    const px: number = Math.round(sizeVp * this.density)
    return (bold ? 'bold ' : '') + px.toString() + 'px sans-serif'
  }

  private accountKey(): string {
    let accountId: string = ''
    try {
      LocalStoreService.init(getContext(this))
      accountId = LocalStoreService.getAccountId()
    } catch (e) {
      console.info('[KnowledgePage] account lookup deferred')
    }
    return accountId.length > 0 ? accountId : 'demo-account'
  }

  private async load(): Promise<void> {
    if (this.isLoading) return
    this.isLoading = true
    this.statusText = '正在加载知识图谱…'
    try {
      const accountId: string = this.accountKey()
      const graph: KnowledgeGraph = await CloudSyncService.graph(accountId)
      this.nodes = graph.nodes
      this.edges = graph.edges
      this.themeCount = graph.stats.themes
      this.itemCount = graph.stats.items
      this.savedCount = graph.stats.saved

      const rec: RecommendResult = await CloudSyncService.recommend(accountId, 5)
      this.recommendations = rec.items

      if (this.nodes.length === 0) {
        this.statusText = '还没有主题和收藏，先去档案页收藏几条再回来'
      } else {
        this.statusText = this.nodes.length + ' 个节点 · ' + this.edges.length + ' 条关联'
      }
      this.draw()
    } catch (e) {
      this.statusText = '加载失败：' + JSON.stringify(e)
    } finally {
      this.isLoading = false
    }
  }

  private draw(): void {
    const ctx: CanvasRenderingContext2D = this.ctx
    const w: number = ctx.width
    const h: number = ctx.height
    if (w <= 0 || h <= 0) return
    ctx.clearRect(0, 0, w, h)

    const themes: GraphNode[] = []
    const items: GraphNode[] = []
    for (let i = 0; i < this.nodes.length; i++) {
      if (this.nodes[i].kind === 'theme') {
        themes.push(this.nodes[i])
      } else {
        items.push(this.nodes[i])
      }
    }

    const cx: number = w / 2
    const cy: number = h / 2
    const outer: number = Math.min(w, h) * 0.34
    const inner: number = Math.min(w, h) * 0.17
    const positions: Map<string, number[]> = new Map<string, number[]>()

    for (let i = 0; i < themes.length; i++) {
      const angle: number = (Math.PI * 2 * i) / Math.max(themes.length, 1) - Math.PI / 2
      positions.set(themes[i].id, [cx + Math.cos(angle) * inner, cy + Math.sin(angle) * inner])
    }
    for (let i = 0; i < items.length; i++) {
      const angle: number = (Math.PI * 2 * i) / Math.max(items.length, 1) - Math.PI / 2
      positions.set(items[i].id, [cx + Math.cos(angle) * outer, cy + Math.sin(angle) * outer])
    }

    for (let i = 0; i < this.edges.length; i++) {
      const edge: GraphEdge = this.edges[i]
      const p1 = positions.get(edge.from)
      const p2 = positions.get(edge.to)
      if (!p1 || !p2) continue
      ctx.beginPath()
      ctx.moveTo(p1[0], p1[1])
      ctx.lineTo(p2[0], p2[1])
      if (edge.kind === 'theme') {
        ctx.lineWidth = 1.4
        ctx.strokeStyle = '#347D7355'
      } else {
        ctx.lineWidth = 0.7
        ctx.strokeStyle = '#A9A29A44'
      }
      ctx.stroke()
    }

    for (let i = 0; i < themes.length; i++) {
      const p = positions.get(themes[i].id)
      if (!p) continue
      ctx.beginPath()
      ctx.arc(p[0], p[1], 18, 0, Math.PI * 2)
      ctx.fillStyle = themes[i].color
      ctx.fill()
      ctx.font = this.font(14, true)
      ctx.fillStyle = themes[i].color
      ctx.textAlign = 'center'
      ctx.textBaseline = 'top'
      ctx.fillText(themes[i].label, p[0], p[1] + 23)
    }

    for (let i = 0; i < items.length; i++) {
      const p = positions.get(items[i].id)
      if (!p) continue
      ctx.beginPath()
      ctx.arc(p[0], p[1], items[i].saved ? 9 : 6, 0, Math.PI * 2)
      ctx.fillStyle = items[i].color
      ctx.fill()
      if (items[i].saved) {
        ctx.beginPath()
        ctx.arc(p[0], p[1], 13, 0, Math.PI * 2)
        ctx.lineWidth = 2
        ctx.strokeStyle = '#B83A2D'
        ctx.stroke()
      }
      ctx.font = this.font(12, false)
      ctx.fillStyle = '#3E4844'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'top'
      const label: string = items[i].label.length > 5 ? items[i].label.substring(0, 5) : items[i].label
      ctx.fillText(label, p[0], p[1] + 14)
    }
  }

  @Builder
  RecommendCard(item: Recommendation) {
    Column({ space: 7 }) {
      Row({ space: 8 }) {
        Divider()
          .vertical(true)
          .height(30)
          .strokeWidth(3)
          .color(item.color)
        Column({ space: 2 }) {
          Text(item.title)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C2C2A')
          Text(item.era + ' · ' + item.city + ' · ' + item.type)
            .fontSize(9)
            .fontColor('#818A87')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Text(item.score.toString())
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor('#B83A2D')
          .padding({ left: 7, right: 7, top: 3, bottom: 3 })
          .backgroundColor('#FBEAE8')
          .borderRadius(9)
      }
      .width('100%')

      Text(item.summary)
        .fontSize(10)
        .fontColor('#5F6A66')
        .lineHeight(15)
        .width('100%')

      ForEach(item.reasons, (reason: string) => {
        Text('· ' + reason)
          .fontSize(9)
          .fontColor('#347D73')
          .width('100%')
      })
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
          Text(this.isLoading ? '同步中…' : '刷新')
            .fontSize(12)
            .fontColor('#B83A2D')
            .padding({ left: 12, top: 4, bottom: 4 })
            .onClick(() => {
              this.load()
            })
        }
        .width('100%')

        Column({ space: 5 }) {
          Text('个人文化知识体系')
            .fontSize(25)
            .fontFamily('serif')
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C2C2A')
          Text('收藏与主题自动织成知识节点网络，并推荐可拓展的条目')
            .fontSize(11)
            .fontColor('#78817E')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Row() {
          // 直接内联，不走 @Builder：@Builder 按值传参不刷新，
          // 之前这里一直显示初始的 0。
          Column({ space: 3 }) {
            Text(this.themeCount.toString())
              .fontSize(19)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E3434')
            Text('文化主题')
              .fontSize(9)
              .fontColor('#7A8480')
          }
          .layoutWeight(1)

          Column({ space: 3 }) {
            Text(this.itemCount.toString())
              .fontSize(19)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E3434')
            Text('知识条目')
              .fontSize(9)
              .fontColor('#7A8480')
          }
          .layoutWeight(1)

          Column({ space: 3 }) {
            Text(this.savedCount.toString())
              .fontSize(19)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E3434')
            Text('个人收藏')
              .fontSize(9)
              .fontColor('#7A8480')
          }
          .layoutWeight(1)

          Column({ space: 3 }) {
            Text(this.edges.length.toString())
              .fontSize(19)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E3434')
            Text('关联边')
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

        Column({ space: 8 }) {
          Canvas(this.ctx)
            .width('100%')
            .height(340)
            .onReady(() => {
              this.draw()
            })
          Text(this.statusText)
            .fontSize(9)
            .fontColor('#818A87')
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)
        .margin({ top: 12 })
        .border({ width: 1, color: '#E5E1D8' })

        Row({ space: 14 }) {
          Row({ space: 5 }) {
            Divider().vertical(true).height(12).strokeWidth(8).color('#347D73')
            Text('文化主题').fontSize(9).fontColor('#7A8480')
          }
          Row({ space: 5 }) {
            Divider().vertical(true).height(12).strokeWidth(8).color('#B34A38')
            Text('知识条目').fontSize(9).fontColor('#7A8480')
          }
          Row({ space: 5 }) {
            Divider().vertical(true).height(12).strokeWidth(1).color('#B83A2D')
            Text('已收藏').fontSize(9).fontColor('#7A8480')
          }
        }
        .width('100%')
        .margin({ top: 8 })

        SectionTitle({ title: '拓展推荐', subtitle: '依据你的主题与标签计算，排除已收藏内容' })

        if (this.recommendations.length === 0) {
          Text('收藏几条档案后，这里会出现与你兴趣相关的拓展条目')
            .fontSize(11)
            .fontColor('#818A87')
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
        } else {
          Column({ space: 10 }) {
            ForEach(this.recommendations, (item: Recommendation) => {
              this.RecommendCard(item)
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
