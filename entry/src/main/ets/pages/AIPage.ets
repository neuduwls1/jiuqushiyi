import { AIChatService, ChatMessage } from '../services/AIChatService'

interface DisplayMessage {
  role: 'user' | 'ai'
  content: string
}

/**
 * 「河小忆」对话页：只聊黄河文化。
 *
 * 布局刻意跟 KnowledgePage / BackupPage 保持一致：
 * 根节点是 Stack，主内容放在一个 height('100%') 的 Scroll 里，
 * 输入条用 Stack 的 Bottom 对齐浮在底部。
 * 这样不依赖 layoutWeight 在 NavDestination 里的高度分配，避免整页高度塌成 0 变白屏。
 */
@Component
export struct AIPage {
  // 用回调关闭，不再依赖 NavPathStack 路由（与 Old-People2 里 AIComponent 直接挂载的方式一致）
  onClose?: () => void

  @State messages: DisplayMessage[] = []
  @State inputText: string = ''
  @State isTyping: boolean = false

  private history: ChatMessage[] = []
  private scroller: Scroller = new Scroller()

  // 展示用快捷问题：覆盖遗址、石窟、文明起源、文学、路线、亲子六类
  private quickAsks: string[] = [
    '二里头为什么被称作最早的中国？',
    '龙门石窟和云冈石窟差在哪？',
    '河洛地区为什么是文明起源地？',
    '杜甫和洛阳有什么关系？',
    '帮我串一条黄河文化一日游',
    '带孩子去博物馆，先看哪三件？'
  ]

  private scrollToBottom(): void {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 60)
  }

  private async ask(text: string): Promise<void> {
    const content: string = text.trim()
    if (content.length === 0 || this.isTyping) {
      return
    }
    this.messages.push({ role: 'user', content: content })
    this.inputText = ''
    this.scrollToBottom()

    if (AIChatService.blocked(content)) {
      this.messages.push({ role: 'ai', content: AIChatService.refusal() })
      this.scrollToBottom()
      return
    }

    this.isTyping = true
    try {
      const reply: string = await AIChatService.chat(this.history, content)
      this.history.push({ role: 'user', content: content })
      this.history.push({ role: 'assistant', content: reply })
      if (this.history.length > 12) {
        this.history = this.history.slice(this.history.length - 12)
      }
      this.messages.push({ role: 'ai', content: reply })
    } catch (e) {
      this.messages.push({ role: 'ai', content: '网络好像不太顺，稍等我一下再问一次。' })
    }
    this.isTyping = false
    this.scrollToBottom()
  }

  private clearChat(): void {
    this.messages = []
    this.history = []
  }

  @Builder
  Bubble(msg: DisplayMessage) {
    if (msg.role === 'user') {
      Row() {
        Blank()
        Text(msg.content)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .lineHeight(21)
          .padding({ left: 13, right: 13, top: 10, bottom: 10 })
          .constraintSize({ maxWidth: '76%' })
          .backgroundColor('#C43D32')
          .borderRadius(14)
      }
      .width('100%')
      .margin({ bottom: 12 })
    } else {
      Row() {
        Text('忆')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(28)
          .height(28)
          .textAlign(TextAlign.Center)
          .backgroundColor('#347D73')
          .borderRadius(14)
          .margin({ right: 8, top: 2 })

        Text(msg.content)
          .fontSize(14)
          .fontColor('#1E3434')
          .lineHeight(21)
          .padding({ left: 13, right: 13, top: 10, bottom: 10 })
          .constraintSize({ maxWidth: '72%' })
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
          .border({ width: 1, color: '#E5E1D8' })

        Blank()
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: 12 })
    }
  }

  @Builder
  QuickChip(text: string) {
    Text(text)
      .fontSize(11)
      .fontColor('#315E78')
      .padding({ left: 11, right: 11, top: 7, bottom: 7 })
      .backgroundColor('#FFFFFF')
      .borderRadius(14)
      .border({ width: 1, color: '#DCE3E0' })
      .margin({ right: 8 })
      .onClick(() => {
        this.ask(text)
      })
  }

  @Builder
  Content() {
    Column({ space: 12 }) {
      // 返回 + 标题
      Row({ space: 10 }) {
        Text('‹ 返回')
          .fontSize(11)
          .fontColor('#59645F')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onClick(() => {
            if (this.onClose) {
              this.onClose()
            }
          })

        Blank()

        if (this.messages.length > 0) {
          Text('清空对话')
            .fontSize(10)
            .fontColor('#7A8581')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#ECE8DF')
            .borderRadius(12)
            .onClick(() => {
              this.clearChat()
            })
        }
      }
      .width('100%')

      Column({ space: 4 }) {
        Text('河小忆')
          .fontSize(22)
          .fontFamily('serif')
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C2C2A')
        Text('黄河文化讲解助手 · 只聊这条河的故事')
          .fontSize(10)
          .fontColor('#78817E')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      // 空态欢迎
      if (this.messages.length === 0) {
        Row({ space: 12 }) {
          Text('忆')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width(40)
            .height(40)
            .textAlign(TextAlign.Center)
            .backgroundColor('#347D73')
            .borderRadius(20)

          Column({ space: 4 }) {
            Text('我是河小忆')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1C2C2A')
            Text('从二里头的绿松石龙，到龙门石窟的卢舍那大佛，你想先听哪一段？')
              .fontSize(11)
              .fontColor('#78817E')
              .lineHeight(17)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(13)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)
        .border({ width: 1, color: '#E5E1D8' })
      }

      // 对话
      ForEach(this.messages, (msg: DisplayMessage, index: number) => {
        this.Bubble(msg)
      }, (msg: DisplayMessage, index: number) => index.toString())

      if (this.isTyping) {
        Text('河小忆正在翻阅典籍…')
          .fontSize(11)
          .fontColor('#8A9490')
          .width('100%')
      }

      // 快捷问题
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.quickAsks, (q: string) => {
          this.QuickChip(q)
        }, (q: string) => q)
      }
      .width('100%')

      // 给底部固定的输入条留出空间
      Row()
        .width('100%')
        .height(78)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll(this.scroller) {
        this.Content()
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)

      // 固定在底部的输入条
      Column() {
        Row({ space: 8 }) {
          TextInput({ text: this.inputText, placeholder: '问我黄河两岸的遗址、朝代与故事' })
            .layoutWeight(1)
            .height(40)
            .fontSize(13)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .placeholderColor('#A9B3AF')
            .onChange((value: string) => {
              this.inputText = value
            })
            .onSubmit(() => {
              this.ask(this.inputText)
            })

          Button('发送')
            .width(62)
            .height(40)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor(this.inputText.trim().length > 0 ? '#C43D32' : '#C9BEB1')
            .borderRadius(12)
            .enabled(this.inputText.trim().length > 0 && !this.isTyping)
            .onClick(() => {
              this.ask(this.inputText)
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 14 })
      .backgroundColor('#F7F4ED')
      .border({ width: { top: 1 }, color: '#E7E1D6' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F4ED')
  }
}
