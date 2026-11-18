import { ArchiveItem, NoteRecord, SyncEntity } from '../models/ArchiveModels'
import { ARCHIVE_ITEMS } from '../data/ArchiveData'
import { TopBar, SectionTitle, MetricBlock, FilterChip } from '../components/EraFilter'
import { ArchiveCard } from '../components/ArchiveCard'
import { LocalStoreService } from '../services/LocalStoreService'
import { CloudSyncService } from '../services/CloudSyncService'

const COLLAPSE_LIMIT: number = 3

interface KnowledgeGroup {
  tag: string
  members: ArchiveItem[]
  color: string
}

interface KnowledgeSuggestion {
  item: ArchiveItem
  score: number
  reasons: string[]
}

@Component
export struct CollectionPage {
  @Link favorites: string[]
  @Link selectedId: string
  @Link currentTab: number
  @Link routeRequest: string
  @Link @Watch('onRemoteNotes') remoteNotesRev: number
  // 打开全屏 AI 对话（由 Index 挂载 AIPage）
  @Link aiOpen: boolean
  @State notes: NoteRecord[] = []
  @State noteText: string = ''
  @State selectedResourceId: string = 'erlitou'
  @State editingNoteId: string = ''
  @State notesExpanded: boolean = false
  @State favoritesExpanded: boolean = false
  @State knowledgeExpanded: boolean = false

  aboutToAppear(): void {
    try {
      LocalStoreService.init(getContext(this))
      this.notes = LocalStoreService.getNotes()
    } catch (e) {
      console.info('[CollectionPage] Load notes deferred')
    }
  }

  private isFavorite(id: string): boolean {
    return this.favorites.indexOf(id) >= 0
  }

  private favoriteItems(): ArchiveItem[] {
    return ARCHIVE_ITEMS.filter((item: ArchiveItem) => this.isFavorite(item.id))
  }

  private visibleNotes(): NoteRecord[] {
    if (this.notesExpanded || this.notes.length <= COLLAPSE_LIMIT) {
      return this.notes
    }
    return this.notes.slice(0, COLLAPSE_LIMIT)
  }

  private visibleKnowledgeGroups(): KnowledgeGroup[] {
    let groups: KnowledgeGroup[] = this.sharedKnowledgeGroups()
    if (this.knowledgeExpanded || groups.length <= COLLAPSE_LIMIT) {
      return groups
    }
    return groups.slice(0, COLLAPSE_LIMIT)
  }

  private visibleFavoriteItems(): ArchiveItem[] {
    let items: ArchiveItem[] = this.favoriteItems()
    if (this.favoritesExpanded || items.length <= COLLAPSE_LIMIT) {
      return items
    }
    return items.slice(0, COLLAPSE_LIMIT)
  }

  private sharedKnowledgeGroups(): KnowledgeGroup[] {
    let favorites: ArchiveItem[] = this.favoriteItems()
    let tags: string[] = []
    for (let i = 0; i < favorites.length; i++) {
      let itemTags: string[] = favorites[i].tags
      for (let j = 0; j < itemTags.length; j++) {
        if (tags.indexOf(itemTags[j]) < 0) {
          tags.push(itemTags[j])
        }
      }
    }

    let groups: KnowledgeGroup[] = []
    for (let i = 0; i < tags.length; i++) {
      let tag: string = tags[i]
      let members: ArchiveItem[] = favorites.filter((item: ArchiveItem) => item.tags.indexOf(tag) >= 0)
      if (members.length >= 2) {
        groups.push({
          tag: tag,
          members: members,
          color: members[0].color
        })
      }
    }
    return groups
  }

  private knowledgeSuggestions(): KnowledgeSuggestion[] {
    let favorites: ArchiveItem[] = this.favoriteItems()
    let favoriteTags: string[] = []
    for (let i = 0; i < favorites.length; i++) {
      let tags: string[] = favorites[i].tags
      for (let j = 0; j < tags.length; j++) {
        if (favoriteTags.indexOf(tags[j]) < 0) {
          favoriteTags.push(tags[j])
        }
      }
    }

    let suggestions: KnowledgeSuggestion[] = []
    for (let i = 0; i < ARCHIVE_ITEMS.length; i++) {
      let item: ArchiveItem = ARCHIVE_ITEMS[i]
      if (this.isFavorite(item.id)) {
        continue
      }
      let reasons: string[] = []
      for (let j = 0; j < item.tags.length; j++) {
        if (favoriteTags.indexOf(item.tags[j]) >= 0) {
          reasons.push(item.tags[j])
        }
      }
      if (reasons.length > 0) {
        suggestions.push({
          item: item,
          score: reasons.length,
          reasons: reasons
        })
      }
    }
    return suggestions.slice(0, 4)
  }

  private groupDescription(tag: string): string {
    if (tag === '都城') return '共同涉及都城选址、城市轴线与礼制布局。'
    if (tag === '青铜') return '共同体现青铜技术、礼器制度与早期国家权力。'
    if (tag === '世界遗产') return '共同具有突出的文化遗产价值和跨区域影响。'
    if (tag === '佛教') return '共同关联佛教传播、寺院营建与造像艺术。'
    if (tag === '石刻') return '共同体现石质材料上的雕塑、题记和时代审美。'
    if (tag === '北宋') return '共同连接北宋东京城及宋代社会生活。'
    if (tag === '东京') return '共同处于北宋东京城市体系与文化记忆中。'
    if (tag === '仰韶') return '共同属于仰韶文化阶段，体现彩陶与聚落发展。'
    if (tag === '彩陶') return '共同以彩陶纹饰反映史前审美与文化交流。'
    if (tag === '古建筑') return '共同保存传统建筑形制和地域营造技艺。'
    if (tag === '石刻') return '共同体现石窟、碑刻与宗教艺术传统。'
    return '共享“' + tag + '”标签，可以放在同一主题下继续比较。'
  }

  private memberNames(group: KnowledgeGroup): string {
    let names: string[] = []
    for (let i = 0; i < group.members.length; i++) {
      names.push(group.members[i].title)
    }
    return names.join(' · ')
  }

  private reasonText(reasons: string[]): string {
    if (reasons.length === 0) return '可继续探索'
    return '共同标签：' + reasons.join(' / ')
  }

  private toggleFavorite(id: string): void {
    if (this.isFavorite(id)) {
      this.favorites = this.favorites.filter((v: string) => v !== id)
    } else {
      this.favorites = [id].concat(this.favorites)
    }
  }

  private resourceTitle(id: string): string {
    for (let i = 0; i < ARCHIVE_ITEMS.length; i++) {
      if (ARCHIVE_ITEMS[i].id === id) {
        return ARCHIVE_ITEMS[i].title
      }
    }
    return '未关联档案'
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
    if (content.length === 0) {
      return
    }

    let timestamp: number = Date.now()
    let saved: NoteRecord = {
      id: '',
      resourceId: this.selectedResourceId,
      content: content,
      tags: [],
      createdAt: timestamp,
      updatedAt: timestamp
    }

    if (this.editingNoteId.length > 0) {
      let updated: NoteRecord[] = []
      for (let i = 0; i < this.notes.length; i++) {
        let note: NoteRecord = this.notes[i]
        if (note.id === this.editingNoteId) {
          saved = {
            id: note.id,
            resourceId: this.selectedResourceId,
            content: content,
            tags: note.tags,
            createdAt: note.createdAt,
            updatedAt: timestamp
          }
          updated.push(saved)
        } else {
          updated.push(note)
        }
      }
      this.notes = updated
      LocalStoreService.saveNotes(updated)
    } else {
      saved = {
        id: 'note_' + timestamp.toString(),
        resourceId: this.selectedResourceId,
        content: content,
        tags: [],
        createdAt: timestamp,
        updatedAt: timestamp
      }
      this.notes = LocalStoreService.addNote(saved)
    }

    this.pushNote(saved, false)
    this.noteText = ''
    this.editingNoteId = ''
  }

  private editNote(note: NoteRecord): void {
    this.selectedResourceId = note.resourceId
    this.noteText = note.content
    this.editingNoteId = note.id
  }

  private deleteNote(noteId: string): void {
    let removed: NoteRecord = {
      id: noteId, resourceId: '', content: '', tags: [], createdAt: 0, updatedAt: 0
    }
    for (let i = 0; i < this.notes.length; i++) {
      if (this.notes[i].id === noteId) {
        removed = this.notes[i]
        break
      }
    }
    let remaining: NoteRecord[] = this.notes.filter((note: NoteRecord) => note.id !== noteId)
    this.notes = remaining
    LocalStoreService.saveNotes(remaining)
    this.pushNote(removed, true)
    if (this.editingNoteId === noteId) {
      this.editingNoteId = ''
      this.noteText = ''
    }
  }

  // 远端推来的笔记变更写进了本地存储，这里重新读一次
  onRemoteNotes(): void {
    this.notes = LocalStoreService.getNotes()
  }

  private pushNote(note: NoteRecord, deleted: boolean): void {
    try {
      const deviceId: string = LocalStoreService.ensureDeviceId()
      const order: number = this.notes.indexOf(note)
      const entity: SyncEntity = CloudSyncService.noteEntity(
        note, deviceId, order < 0 ? 0 : order, deleted)
      CloudSyncService.push(LocalStoreService.accountKey(), deviceId, [entity])
        .then(() => {
          console.info('[CollectionPage] note synced')
        })
        .catch(() => {
          console.info('[CollectionPage] note sync deferred')
        })
    } catch (e) {
      console.info('[CollectionPage] note sync skipped')
    }
  }

  @Builder
  KnowledgeGroupCard(group: KnowledgeGroup) {
    Column({ space: 9 }) {
      Row() {
        Text(group.tag)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(group.color)
          .borderRadius(10)
        Text(group.members.length + ' 个地点')
          .fontSize(9)
          .fontColor('#78817E')
          .margin({ left: 8 })
        Blank()
        Text('共同点')
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor(group.color)
      }
      .width('100%')

      Text(this.memberNames(group))
        .fontSize(13)
        .fontFamily('serif')
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E3434')
        .width('100%')

      Text(this.groupDescription(group.tag))
        .fontSize(10)
        .fontColor('#5F6B67')
        .lineHeight(16)
        .width('100%')

      Row({ space: 6 }) {
        ForEach(group.members, (item: ArchiveItem) => {
          Text(item.city)
            .fontSize(8)
            .fontColor('#5B6F69')
            .padding({ left: 7, right: 7, top: 4, bottom: 4 })
            .backgroundColor('#EEF2EE')
            .borderRadius(8)
        })
      }
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .border({ width: 1, color: '#E5E1D8' })
    .onClick(() => {
      this.selectedId = group.members[0].id
    })
  }

  @Builder
  KnowledgeSuggestionCard(suggestion: KnowledgeSuggestion) {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text(suggestion.item.title)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E3434')
        Text(suggestion.item.city + ' · ' + suggestion.item.era + ' · ' + suggestion.item.type)
          .fontSize(8)
          .fontColor('#7B8581')
        Text(this.reasonText(suggestion.reasons))
          .fontSize(9)
          .fontColor('#347D73')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('补充  →')
        .fontSize(9)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .padding({ left: 10, right: 10, top: 7, bottom: 7 })
        .backgroundColor('#B83A2D')
        .borderRadius(10)
        .onClick(() => {
          this.selectedId = suggestion.item.id
        })
    }
    .width('100%')
    .padding(13)
    .backgroundColor('#FFFFFF')
    .borderRadius(13)
    .border({ width: 1, color: '#E6E1D8' })
  }

  @Builder
  NoteCard(note: NoteRecord) {
    Column({ space: 8 }) {
      Row() {
        Column({ space: 3 }) {
          Text(this.resourceTitle(note.resourceId))
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E3434')
          Text(this.formatNoteTime(note.updatedAt))
            .fontSize(8)
            .fontColor('#89918E')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row({ space: 6 }) {
          Text('编辑')
            .fontSize(9)
            .fontWeight(FontWeight.Bold)
            .fontColor('#244D6A')
            .padding({ left: 8, right: 8, top: 5, bottom: 5 })
            .backgroundColor('#E9EFF5')
            .borderRadius(9)
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

  @Builder
  KnowledgeToggle() {
    Row({ space: 6 }) {
      Text(this.knowledgeExpanded ? '收起共同点' : '展开全部 ' + this.sharedKnowledgeGroups().length + ' 组共同点')
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor('#315E78')
      Text(this.knowledgeExpanded ? '▲' : '▼')
        .fontSize(9)
        .fontColor('#315E78')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#E5E1D8' })
    .onClick(() => { this.knowledgeExpanded = !this.knowledgeExpanded })
  }

  @Builder
  NotesToggle() {
    Row({ space: 6 }) {
      Text(this.notesExpanded ? '收起历史笔记' : '展开全部 ' + this.notes.length + ' 条笔记')
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor('#315E78')
      Text(this.notesExpanded ? '▲' : '▼')
        .fontSize(9)
        .fontColor('#315E78')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#E5E1D8' })
    .onClick(() => { this.notesExpanded = !this.notesExpanded })
  }

  @Builder
  FavoritesToggle() {
    Row({ space: 6 }) {
      Text(this.favoritesExpanded ? '收起收藏节点' : '展开全部 ' + this.favoriteItems().length + ' 个收藏节点')
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor('#315E78')
      Text(this.favoritesExpanded ? '▲' : '▼')
        .fontSize(9)
        .fontColor('#315E78')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#E5E1D8' })
    .onClick(() => { this.favoritesExpanded = !this.favoritesExpanded })
  }

  build() {
    Scroll() {
      Column({ space: 13 }) {
        TopBar({ currentTab: $currentTab })
        Column({ space: 5 }) {
          Text('我的文化记忆库')
            .fontSize(25)
            .fontFamily('serif')
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C2C2A')
          Text('收藏、笔记与标签共同形成个人研究脉络')
            .fontSize(11)
            .fontColor('#78817E')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Row() {
          MetricBlock({ value: this.favorites.length.toString(), label: '已收藏' })
          MetricBlock({ value: this.notes.length.toString(), label: '个人笔记' })
          MetricBlock({ value: '3', label: '文化主题' })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(14)

        Row({ space: 10 }) {
          Column({ space: 3 }) {
            Text('个人文化知识体系')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1C2C2A')
            Text('主题网络 · 拓展推荐 · 云端图谱')
              .fontSize(9)
              .fontColor('#818A87')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('打开 →')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor('#347D73')
            .borderRadius(14)
        }
        .width('100%')
        .padding(13)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)
        .border({ width: 1, color: '#E5E1D8' })
        .onClick(() => {
          this.routeRequest = 'knowledge'
        })

        Row({ space: 10 }) {
          Text('忆')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width(32)
            .height(32)
            .textAlign(TextAlign.Center)
            .backgroundColor('#347D73')
            .borderRadius(16)

          Column({ space: 3 }) {
            Text('河小忆 · AI 文化问答')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1C2C2A')
            Text('问她遗址、朝代、诗词与路线')
              .fontSize(9)
              .fontColor('#818A87')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('对话 →')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor('#C43D32')
            .borderRadius(14)
        }
        .width('100%')
        .padding(13)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)
        .border({ width: 1, color: '#E5E1D8' })
        .onClick(() => {
          this.aiOpen = true
        })

        SectionTitle({
          title: '个人知识图谱',
          subtitle: '自动提取收藏地点之间的共同标签与文化联系'
        })
        Column({ space: 10 }) {
          Column({ space: 4 }) {
            Text(this.favoriteItems().length + ' 个收藏节点')
              .fontSize(16)
              .fontFamily('serif')
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E3434')
            Text(
              this.sharedKnowledgeGroups().length > 0
                ? '已发现 ' + this.sharedKnowledgeGroups().length + ' 组共同点'
                : '暂未发现两个以上地点共享同一标签'
            )
              .fontSize(9)
              .fontColor('#6F7975')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          if (this.sharedKnowledgeGroups().length > 0) {
            ForEach(this.visibleKnowledgeGroups(), (group: KnowledgeGroup) => {
              this.KnowledgeGroupCard(group)
            })
            if (this.sharedKnowledgeGroups().length > COLLAPSE_LIMIT) {
              this.KnowledgeToggle()
            }
          } else if (this.favoriteItems().length < 2) {
            Column({ space: 6 }) {
              Text('收藏内容较少')
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor('#59645F')
              Text('至少收藏两个不同地点，系统才能计算共同标签与知识关系。')
                .fontSize(10)
                .fontColor('#7B8581')
                .textAlign(TextAlign.Center)
                .lineHeight(16)
              Button('去了解更多地方')
                .height(36)
                .fontSize(10)
                .backgroundColor('#B83A2D')
                .onClick(() => { this.currentTab = 1 })
            }
            .width('100%')
            .padding(18)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(13)
          } else {
            Column({ space: 6 }) {
              Text('收藏之间暂未发现共同标签')
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor('#59645F')
              Text('当前内容较少。可以再补充一期文化、同一类遗址或同一座城市的收藏，让知识图谱形成更多连接。')
                .fontSize(10)
                .fontColor('#7B8581')
                .textAlign(TextAlign.Center)
                .lineHeight(16)
            }
            .width('100%')
            .padding(18)
            .backgroundColor('#FFFFFF')
            .borderRadius(13)
          }

          if (this.knowledgeSuggestions().length > 0) {
            Text('建议补充的地点')
              .fontSize(13)
              .fontFamily('serif')
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E3434')
              .width('100%')
              .margin({ top: 4 })

            ForEach(this.knowledgeSuggestions(), (suggestion: KnowledgeSuggestion) => {
              this.KnowledgeSuggestionCard(suggestion)
            })
          } else {
            Text('暂时没有可推荐的关联地点，请再去了解更多地方吧。')
              .fontSize(10)
              .fontColor('#7B8581')
              .width('100%')
              .padding(14)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(14)
        .backgroundColor('#F4EFE5')
        .borderRadius(14)

        SectionTitle({
          title: this.editingNoteId.length > 0 ? '编辑笔记' : '写一条笔记',
          subtitle: '先选择关联档案，再记录考古线索或参观计划'
        })
        Column({ space: 10 }) {
          Scroll() {
            Row({ space: 8 }) {
              ForEach(ARCHIVE_ITEMS, (item: ArchiveItem) => {
                FilterChip({
                  label: item.title,
                  selected: this.selectedResourceId === item.id,
                  onSelect: () => { this.selectedResourceId = item.id }
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          TextArea({ placeholder: '记录考古线索、参观计划或待查证的问题…', text: this.noteText })
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
                  this.editingNoteId = ''
                  this.noteText = ''
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
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#F4EFE5')
        .borderRadius(14)

        SectionTitle({
          title: '历史笔记',
          subtitle: this.notes.length > 0 ? '共 ' + this.notes.length + ' 条，可按时间查看和继续编辑' : '还没有保存过笔记'
        })
        if (this.notes.length === 0) {
          Column({ space: 6 }) {
            Text('✎')
              .fontSize(28)
              .fontColor('#B7A991')
            Text('保存后的笔记会显示在这里')
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor('#59645F')
            Text('重新打开应用后仍然可以查看')
              .fontSize(9)
              .fontColor('#89918E')
          }
          .width('100%')
          .height(130)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
        } else {
          ForEach(this.visibleNotes(), (note: NoteRecord) => {
            this.NoteCard(note)
          })
          if (this.notes.length > COLLAPSE_LIMIT) {
            this.NotesToggle()
          }
        }

        SectionTitle({
          title: '已收藏档案',
          subtitle: this.favoriteItems().length > 0
            ? '共 ' + this.favoriteItems().length + ' 个收藏节点，离线编辑会在网络恢复后自动合并'
            : '还没有收藏任何档案'
        })
        if (this.favoriteItems().length === 0) {
          Column({ space: 6 }) {
            Text('☆')
              .fontSize(28)
              .fontColor('#B7A991')
            Text('收藏后的档案会显示在这里')
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor('#59645F')
            Text('在档案页点击收藏即可加入个人记忆库')
              .fontSize(9)
              .fontColor('#89918E')
          }
          .width('100%')
          .height(130)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
        } else {
          ForEach(this.visibleFavoriteItems(), (item: ArchiveItem) => {
            ArchiveCard({
              item: item,
              isFav: true,
              onToggleFav: (id: string) => { this.toggleFavorite(id) },
              onCardClick: (id: string) => { this.selectedId = id }
            })
          })
          if (this.favoriteItems().length > COLLAPSE_LIMIT) {
            this.FavoritesToggle()
          }
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
