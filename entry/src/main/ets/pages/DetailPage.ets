import { ArchiveItem, NoteRecord } from '../models/ArchiveModels'
import { ARCHIVE_ITEMS } from '../data/ArchiveData'
import { SectionTitle } from '../components/EraFilter'
import { LocalStoreService } from '../services/LocalStoreService'

let isShouJinFontRegistered: boolean = false

@Component
export struct DetailPage {
  @Link selectedId: string
  @Link favorites: string[]
  @State detailNotes: NoteRecord[] = []
  @State noteText: string = ''
  @State editingNoteId: string = ''

  aboutToAppear(): void {
    try {
      LocalStoreService.init(getContext(this))
      this.loadNotes()
    } catch (error) {
      console.error('[DetailPage] local note storage init failed', JSON.stringify(error))
    }

    if (!isShouJinFontRegistered) {
      try {
        this.getUIContext().getFont().registerFont({
          familyName: 'ShouJinShu',
          familySrc: $rawfile('fonts/AaCuiZhuXianHeShouJinShu.ttf')
        })
        isShouJinFontRegistered = true
      } catch (error) {
        console.error('[DetailPage] shoujin font registration failed', JSON.stringify(error))
      }
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

  private selectedItem(): ArchiveItem {
    let result: ArchiveItem = ARCHIVE_ITEMS[0]
    for (let i = 0; i < ARCHIVE_ITEMS.length; i++) {
      if (ARCHIVE_ITEMS[i].id === this.selectedId) {
        result = ARCHIVE_ITEMS[i]
        break
      }
    }
    return result
  }

  private loadNotes(): void {
    let resourceId: string = this.selectedItem().id
    this.detailNotes = LocalStoreService.getNotes().filter((note: NoteRecord) => note.resourceId === resourceId)
  }

  private formatNoteTime(timestamp: number): string {
    let date: Date = new Date(timestamp)
    let month: string = (date.getMonth() + 1).toString().padStart(2, '0')
    let day: string = date.getDate().toString().padStart(2, '0')
    let hour: string = date.getHours().toString().padStart(2, '0')
    let minute: string = date.getMinutes().toString().padStart(2, '0')
    return month + '月' + day + '日 ' + hour + ':' + minute
  }

  private saveNote(): void {
    let content: string = this.noteText.trim()
    if (content.length === 0) return

    let timestamp: number = Date.now()
    let allNotes: NoteRecord[] = LocalStoreService.getNotes()
    if (this.editingNoteId.length > 0) {
      let updated: NoteRecord[] = []
      for (let i = 0; i < allNotes.length; i++) {
        let note: NoteRecord = allNotes[i]
        if (note.id === this.editingNoteId) {
          updated.push({
            id: note.id,
            resourceId: note.resourceId,
            content: content,
            tags: note.tags,
            createdAt: note.createdAt,
            updatedAt: timestamp
          })
        } else {
          updated.push(note)
        }
      }
      LocalStoreService.saveNotes(updated)
    } else {
      let note: NoteRecord = {
        id: 'note_' + timestamp.toString(),
        resourceId: this.selectedItem().id,
        content: content,
        tags: [],
        createdAt: timestamp,
        updatedAt: timestamp
      }
      allNotes.unshift(note)
      LocalStoreService.saveNotes(allNotes)
    }

    this.noteText = ''
    this.editingNoteId = ''
    this.loadNotes()
  }

  private editNote(note: NoteRecord): void {
    this.noteText = note.content
    this.editingNoteId = note.id
  }

  private deleteNote(noteId: string): void {
    let remaining: NoteRecord[] = LocalStoreService.getNotes().filter((note: NoteRecord) => note.id !== noteId)
    LocalStoreService.saveNotes(remaining)
    if (this.editingNoteId === noteId) {
      this.noteText = ''
      this.editingNoteId = ''
    }
    this.loadNotes()
  }

  // 详情页 Hero 底图：与列表卡共用同一套 id → 图片资源映射
  private heroImageRes(item: ArchiveItem): Resource {
    if (item.id === 'yangshao') { return $r('app.media.yangshao') }
    else if (item.id === 'erlitou') { return $r('app.media.erlitou') }
    else if (item.id === 'shangcheng') { return $r('app.media.shangcheng') }
    else if (item.id === 'yin') { return $r('app.media.yin') }
    else if (item.id === 'longmen') { return $r('app.media.longmen') }
    else if (item.id === 'baimasi') { return $r('app.media.baimasi') }
    else if (item.id === 'zhouqiao') { return $r('app.media.zhouqiao') }
    else if (item.id === 'tieta') { return $r('app.media.tieta') }
    else if (item.id === 'miaodigou') { return $r('app.media.miaodigou') }
    else if (item.id === 'yanshi-shang') { return $r('app.media.yanshi_shang') }
    else if (item.id === 'dahecun') { return $r('app.media.dahecun') }
    else if (item.id === 'hanwei-luoyang') { return $r('app.media.hanwei_luoyang') }
    else if (item.id === 'gongyi-grotto') { return $r('app.media.gongyi_grotto') }
    else if (item.id === 'songling') { return $r('app.media.songling') }
    else if (item.id === 'xishuipo') { return $r('app.media.xishuipo') }
    else if (item.id === 'huangye-kiln') { return $r('app.media.huangye_kiln') }
    else if (item.id === 'qicheng') { return $r('app.media.qicheng') }
    else if (item.id === 'dongzhou-wangcheng') { return $r('app.media.dongzhou_wangcheng') }
    else if (item.id === 'suiyang-luoyang') { return $r('app.media.suiyang_luoyang') }
    else if (item.id === 'youlicheng') { return $r('app.media.youlicheng') }
    else if (item.id === 'hanjiaguan') { return $r('app.media.hanjiaguan') }
    else if (item.id === 'jiahu') { return $r('app.media.jiahu') }
    else if (item.id === 'huaiyang-pingliangtai') { return $r('app.media.huaiyang_pingliangtai') }
    return $r('app.media.yangshao')
  }

  @Builder
  DetailBullet(idx: number, text: string) {
    Row({ space: 10 }) {
      Text(idx < 9 ? '0' + (idx + 1).toString() : (idx + 1).toString())
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width(28)
        .height(28)
        .textAlign(TextAlign.Center)
        .backgroundColor('#347D73')
        .borderRadius(14)
      Text(text)
        .fontSize(11)
        .fontColor('#52605B')
        .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  NoteCard(note: NoteRecord) {
    Column({ space: 8 }) {
      Row() {
        Text(this.formatNoteTime(note.updatedAt))
          .fontSize(8)
          .fontColor('#89918E')
          .layoutWeight(1)
        Text('编辑')
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor('#244D6A')
          .padding({ left: 8, right: 8, top: 5, bottom: 5 })
          .backgroundColor('#E9EFF5')
          .borderRadius(9)
          .margin({ right: 6 })
          .onClick(() => { this.editNote(note) })
        Text('删除')
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor('#B83A2D')
          .padding({ left: 8, right: 8, top: 5, bottom: 5 })
          .backgroundColor('#F8ECE8')
          .borderRadius(9)
          .onClick(() => { this.deleteNote(note.id) })
      }
      .width('100%')

      Text(note.content)
        .fontSize(11)
        .fontColor('#4F5B57')
        .lineHeight(18)
        .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(13)
    .backgroundColor('#FFFFFF')
    .borderRadius(13)
    .border({ width: 1, color: '#E6E1D8' })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.xuan_paper_07_light'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .interpolation(ImageInterpolation.High)

      Scroll() {
        Column() {
        Row() {
          Text('←')
            .fontSize(22)
            .fontColor('#1E3434')
            .width(42)
            .height(42)
            .textAlign(TextAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(21)
            .onClick(() => { this.selectedId = '' })
          Blank()
          Text(this.isFavorite(this.selectedItem().id) ? '★ 已收藏' : '☆ 收藏')
            .fontSize(11)
            .fontColor(this.isFavorite(this.selectedItem().id) ? '#B83A2D' : '#59645F')
            .padding({ left: 13, right: 13, top: 9, bottom: 9 })
            .backgroundColor('#FFFFFF')
            .borderRadius(18)
            .onClick(() => { this.toggleFavorite(this.selectedItem().id) })
        }
        .width('100%')
        .height(54)

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(this.heroImageRes(this.selectedItem()))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              angle: 180,
              colors: [
                ['#4D080F0E', 0.0],
                ['#4D080F0E', 0.18],
                ['#80080F0E', 0.50],
                ['#AA080F0E', 0.65],
                ['#E0080F0E', 1.0]
              ]
            })
          Column() {
            Text(this.selectedItem().era + ' · ' + this.selectedItem().city)
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E5C77B')
            Text(this.selectedItem().title)
              .fontSize(33)
              .fontFamily('serif')
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ top: 10 })
            Text(this.selectedItem().period + ' · ' + this.selectedItem().type)
              .fontSize(11)
              .fontColor('#CDDDD9')
              .margin({ top: 10 })
          }
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.End)
          .width('100%')
          .height('100%')
          .padding(22)
        }
        .width('100%')
        .height(250)
        .borderRadius(18)
        .clip(true)

        Column({ space: 12 }) {
          Text('档案概述')
            .fontSize(19)
            .fontFamily('serif')
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Text(this.selectedItem().summary)
            .fontSize(13)
            .fontColor('#4F5B57')
            .lineHeight(22)
            .width('100%')
          Row({ space: 8 }) {
            ForEach(this.selectedItem().tags, (tag: string) => {
              Text(tag)
                .fontSize(9)
                .fontColor('#376A60')
                .padding({ left: 9, right: 9, top: 5, bottom: 5 })
                .backgroundColor('#E7F1EC')
                .borderRadius(9)
            })
          }
          .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)

        SectionTitle({ title: '考古发现', subtitle: '本地离线内容' })
        Column({ space: 10 }) {
          ForEach(this.selectedItem().discoveries, (text: string, index: number) => {
            this.DetailBullet(index, text)
          })
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)

        SectionTitle({
          title: this.editingNoteId.length > 0 ? '编辑笔记' : '我的笔记',
          subtitle: this.detailNotes.length > 0
            ? '共 ' + this.detailNotes.length + ' 条，可继续编辑'
            : '记录参观计划、研究线索或补充资料'
        })
        Column({ space: 10 }) {
          TextArea({
            placeholder: '记录参观计划、研究线索或补充资料…',
            text: this.noteText
          })
            .height(110)
            .fontSize(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(12)
            .onChange((value: string) => { this.noteText = value })

          Row({ space: 8 }) {
            if (this.editingNoteId.length > 0) {
              Button('取消编辑')
                .layoutWeight(1)
                .height(42)
                .fontSize(12)
                .fontColor('#59645F')
                .backgroundColor('#ECE8DF')
                .onClick(() => {
                  this.noteText = ''
                  this.editingNoteId = ''
                })
            }
            Button(this.editingNoteId.length > 0 ? '保存修改' : '保存笔记')
              .layoutWeight(1)
              .height(42)
              .fontSize(12)
              .backgroundColor('#B83A2D')
              .onClick(() => { this.saveNote() })
          }
          .width('100%')

          if (this.detailNotes.length === 0) {
            Text('这条档案还没有笔记，保存后会显示在这里。')
              .fontSize(10)
              .fontColor('#7B8581')
              .width('100%')
              .padding(14)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
          } else {
            ForEach(this.detailNotes, (note: NoteRecord) => {
              this.NoteCard(note)
            })
          }
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#F4EFE5')
        .borderRadius(14)

        if (this.selectedItem().poems.length > 0) {
          SectionTitle({ title: '相关诗词', subtitle: '历代文人吟咏' })
          Column({ space: 8 }) {
            ForEach(this.selectedItem().poems, (poem: string) => {
              Text(poem)
                .fontSize(19.5)
                .fontFamily('ShouJinShu')
                .fontColor('#3A4541')
                .lineHeight(33)
                .width('100%')
                .padding(12)
                .backgroundColor('#F7F4ED')
                .borderRadius(10)
            })
          }
          .width('100%')
        }

        SectionTitle({ title: '文旅信息', subtitle: '参观与交通' })
        Column() {
          Text(this.selectedItem().travel)
            .fontSize(11)
            .fontColor('#4F5B57')
            .lineHeight(18)
            .width('100%')
            .padding(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
        }
        .width('100%')

        Button(this.isFavorite(this.selectedItem().id) ? '已加入 ✓' : '加入我的文化记忆库')
          .width('100%')
          .height(46)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isFavorite(this.selectedItem().id) ? '#347D73' : '#B83A2D')
          .onClick(() => {
            if (!this.isFavorite(this.selectedItem().id)) {
              this.toggleFavorite(this.selectedItem().id)
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 28 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
