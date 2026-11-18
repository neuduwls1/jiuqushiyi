import { http, webSocket } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { SyncEntity, FieldVersion, NoteRecord } from '../models/ArchiveModels'

export interface SyncStats {
  received: number
  applied: number
  conflicts: number
  stored: number
}

export interface DevicePresence {
  deviceId: string
  lastSeen: number
}

export interface SyncSnapshot {
  ok: boolean
  accountId: string
  serverTime: number
  updatedAt: number
  entityCount: number
  fieldCount: number
  devices: DevicePresence[]
  entities: SyncEntity[]
}

export interface SyncPushResult {
  ok: boolean
  accountId: string
  serverTime: number
  deviceId: string
  stats: SyncStats
  devices: DevicePresence[]
  entities: SyncEntity[]
}

export interface SyncOutcome {
  success: boolean
  message: string
  stats: SyncStats
  entities: SyncEntity[]
  devices: DevicePresence[]
}

export interface GraphNode {
  id: string
  kind: string
  label: string
  color: string
  saved: boolean
  itemId: string
  city: string
  era: string
  type: string
  tags: string[]
  description: string
}

export interface GraphEdge {
  id: string
  from: string
  to: string
  kind: string
  weight: number
}

export interface GraphStats {
  themes: number
  items: number
  saved: number
  themeEdges: number
  similarEdges: number
}

export interface KnowledgeGraph {
  ok: boolean
  nodes: GraphNode[]
  edges: GraphEdge[]
  stats: GraphStats
}

export interface Recommendation {
  id: string
  title: string
  city: string
  era: string
  type: string
  summary: string
  color: string
  tags: string[]
  score: number
  reasons: string[]
}

export interface RecommendResult {
  ok: boolean
  savedCount: number
  totalCatalog: number
  items: Recommendation[]
}

export interface BackupCounts {
  favorite: number
  note: number
  theme: number
  relation: number
}

export interface BackupSummary {
  backupId: string
  accountId: string
  createdAt: number
  label: string
  entityCount: number
  counts: BackupCounts
}

export interface BackupList {
  ok: boolean
  backups: BackupSummary[]
}

export interface RestoreResult {
  ok: boolean
  restoredEntities: number
  snapshot: BackupSummary
}

export interface SyncConflict {
  entityId: string
  field: string
  winnerDevice: string
  winnerAt: number
  loserDevice: string
  loserAt: number
}

export interface SyncLogEntry {
  at: number
  deviceId: string
  received: number
  applied: number
  conflicts: number
  stored: number
  details: SyncConflict[]
}

export interface SyncLogResult {
  ok: boolean
  accountId: string
  entries: SyncLogEntry[]
}

interface SyncPushPayload {
  accountId: string
  deviceId: string
  entities: SyncEntity[]
}

interface SyncEnvelope {
  event: string
  payload: Object
}

// Replace with your own sync service URL before enabling cloud sync.
const DEFAULT_BASE_URL: string = ''
// Do not commit a real sync token. Configure it on the device before enabling cloud sync.
const DEFAULT_TOKEN: string = ''

export class CloudSyncService {
  private static baseUrl: string = DEFAULT_BASE_URL
  private static token: string = DEFAULT_TOKEN
  private static socket: webSocket.WebSocket | null = null

  // 实时通道的重连与心跳状态：切后台、网络抖动、服务端重启都会断连，
  // 断连后必须能自己回来，并且在回来时补拉一次漏掉的变更。
  private static liveAccountId: string = ''
  private static liveDeviceId: string = ''
  private static liveOnEvent: (event: string, payload: Object) => void = () => {}
  private static liveOnOpen: () => void = () => {}
  private static liveReady: boolean = false
  private static reconnectTimer: number = -1
  private static heartbeatTimer: number = -1
  private static reconnectAttempts: number = 0
  private static lastServerFrameAt: number = 0
  private static intentionallyClosed: boolean = false

  static configure(baseUrl: string, token: string): void {
    CloudSyncService.baseUrl = baseUrl
    CloudSyncService.token = token
  }

  static currentBaseUrl(): string {
    return CloudSyncService.baseUrl
  }

  static isConfigured(): boolean {
    return CloudSyncService.token.length > 0 && CloudSyncService.baseUrl.length > 0
  }

  private static field(value: Object, updatedAt: number, deviceId: string): FieldVersion<Object> {
    return { value: value, updatedAt: updatedAt, deviceId: deviceId, version: 1 }
  }

  // 收藏：每个条目一个实体，取消收藏用 state=false 表达，而不是删掉，
  // 否则"取消"这个动作没法同步给别的设备。
  static favoriteEntity(itemId: string, favorited: boolean, deviceId: string, now: number): SyncEntity {
    const fields: Record<string, FieldVersion<Object>> = {}
    fields['resourceId'] = CloudSyncService.field(itemId, now, deviceId)
    fields['state'] = CloudSyncService.field(favorited, now, deviceId)
    if (favorited) {
      // 取消收藏时不写 createdAt，保住原本的收藏时间
      fields['createdAt'] = CloudSyncService.field(now, now, deviceId)
    }
    return { entityId: 'fav:' + itemId, entityType: 'favorite', fields: fields }
  }

  static favoriteEntities(ids: string[], deviceId: string, now: number): SyncEntity[] {
    const out: SyncEntity[] = []
    for (let i = 0; i < ids.length; i++) {
      out.push(CloudSyncService.favoriteEntity(ids[i], true, deviceId, now))
    }
    return out
  }

  static noteEntities(notes: NoteRecord[], deviceId: string): SyncEntity[] {
    const out: SyncEntity[] = []
    for (let i = 0; i < notes.length; i++) {
      out.push(CloudSyncService.noteEntity(notes[i], deviceId, i, false))
    }
    return out
  }

  // 删除笔记发的是墓碑（deleted=true），而不是把实体删掉，
  // 否则"删除"这个动作同步不到别的设备。
  static noteEntity(note: NoteRecord, deviceId: string, order: number, deleted: boolean): SyncEntity {
    const stamp: number = deleted
      ? Date.now()
      : (note.updatedAt > 0 ? note.updatedAt : note.createdAt)
    const fields: Record<string, FieldVersion<Object>> = {}
    fields['resourceId'] = CloudSyncService.field(note.resourceId, stamp, deviceId)
    fields['content'] = CloudSyncService.field(note.content, stamp, deviceId)
    fields['tags'] = CloudSyncService.field(note.tags, stamp, deviceId)
    fields['order'] = CloudSyncService.field(order, stamp, deviceId)
    fields['createdAt'] = CloudSyncService.field(note.createdAt, stamp, deviceId)
    fields['updatedAt'] = CloudSyncService.field(stamp, stamp, deviceId)
    fields['deleted'] = CloudSyncService.field(deleted, stamp, deviceId)
    return { entityId: 'note:' + note.id, entityType: 'note', fields: fields }
  }

  private static async request(path: string, method: http.RequestMethod, body: string): Promise<string> {
    const request = http.createHttp()
    try {
      const options: http.HttpRequestOptions = {
        method: method,
        header: {
          'Content-Type': 'application/json',
          'x-sync-token': CloudSyncService.token
        },
        connectTimeout: 8000,
        readTimeout: 8000,
        expectDataType: http.HttpDataType.STRING
      }
      if (body.length > 0) {
        options.extraData = body
      }
      const response: http.HttpResponse = await request.request(CloudSyncService.baseUrl + path, options)
      if (response.responseCode !== 200) {
        throw new Error('服务器返回 ' + response.responseCode)
      }
      return response.result as string
    } finally {
      request.destroy()
    }
  }

  static async push(accountId: string, deviceId: string, entities: SyncEntity[]): Promise<SyncOutcome> {
    const payload: SyncPushPayload = { accountId: accountId, deviceId: deviceId, entities: entities }
    const raw: string = await CloudSyncService.request('/api/v1/sync', http.RequestMethod.POST, JSON.stringify(payload))
    const parsed = JSON.parse(raw) as SyncPushResult
    return {
      success: parsed.ok === true,
      message: '同步完成：应用 ' + parsed.stats.applied + ' 处变更，冲突 ' + parsed.stats.conflicts + ' 处',
      stats: parsed.stats,
      entities: parsed.entities,
      devices: parsed.devices
    }
  }

  static async pull(accountId: string): Promise<SyncSnapshot> {
    const raw: string = await CloudSyncService.request(
      '/api/v1/state?accountId=' + encodeURIComponent(accountId),
      http.RequestMethod.GET,
      ''
    )
    return JSON.parse(raw) as SyncSnapshot
  }

  static async backup(accountId: string, deviceId: string, label: string): Promise<string> {
    const raw: string = await CloudSyncService.request(
      '/api/v1/backup',
      http.RequestMethod.POST,
      JSON.stringify({ accountId: accountId, deviceId: deviceId, label: label })
    )
    const parsed = JSON.parse(raw) as Object
    const backup = (parsed as Record<string, Object>)['backup'] as Record<string, Object>
    return String(backup['backupId'])
  }

  static async graph(accountId: string): Promise<KnowledgeGraph> {
    const raw: string = await CloudSyncService.request(
      '/api/v1/graph?accountId=' + encodeURIComponent(accountId),
      http.RequestMethod.GET,
      ''
    )
    return JSON.parse(raw) as KnowledgeGraph
  }

  static async recommend(accountId: string, limit: number): Promise<RecommendResult> {
    const raw: string = await CloudSyncService.request(
      '/api/v1/recommend?accountId=' + encodeURIComponent(accountId) + '&limit=' + limit.toString(),
      http.RequestMethod.GET,
      ''
    )
    return JSON.parse(raw) as RecommendResult
  }

  static async listBackups(accountId: string): Promise<BackupList> {
    const raw: string = await CloudSyncService.request(
      '/api/v1/backups?accountId=' + encodeURIComponent(accountId),
      http.RequestMethod.GET,
      ''
    )
    return JSON.parse(raw) as BackupList
  }

  static async restore(accountId: string, backupId: string): Promise<RestoreResult> {
    const raw: string = await CloudSyncService.request(
      '/api/v1/restore',
      http.RequestMethod.POST,
      JSON.stringify({ accountId: accountId, backupId: backupId })
    )
    return JSON.parse(raw) as RestoreResult
  }

  static async log(accountId: string, limit: number): Promise<SyncLogResult> {
    const raw: string = await CloudSyncService.request(
      '/api/v1/log?accountId=' + encodeURIComponent(accountId) + '&limit=' + limit.toString(),
      http.RequestMethod.GET,
      ''
    )
    return JSON.parse(raw) as SyncLogResult
  }

  // ---- 反向还原：设备迁移 / 一键恢复时把云端实体写回本地 ----

  static entitiesToFavorites(entities: SyncEntity[]): string[] {
    const out: string[] = []
    for (let i = 0; i < entities.length; i++) {
      const entity: SyncEntity = entities[i]
      if (entity.entityType !== 'favorite') continue
      const state = entity.fields['state']
      if (state && String(state.value) === 'false') continue
      const resourceId = entity.fields['resourceId']
      let id: string = resourceId ? String(resourceId.value) : ''
      if (id.length === 0 && entity.entityId.startsWith('fav:')) {
        id = entity.entityId.slice(4)
      }
      if (id.length > 0 && out.indexOf(id) < 0) out.push(id)
    }
    return out
  }

  static entitiesToNotes(entities: SyncEntity[]): NoteRecord[] {
    const out: NoteRecord[] = []
    for (let i = 0; i < entities.length; i++) {
      const entity: SyncEntity = entities[i]
      if (entity.entityType !== 'note') continue
      const content = entity.fields['content']
      if (!content) continue
      const deletedFlag = entity.fields['deleted']
      if (deletedFlag && String(deletedFlag.value) === 'true') continue
      const resourceId = entity.fields['resourceId']
      const tagsField = entity.fields['tags']
      const createdField = entity.fields['createdAt']
      const updatedField = entity.fields['updatedAt']
      out.push({
        id: entity.entityId.startsWith('note:') ? entity.entityId.slice(5) : entity.entityId,
        resourceId: resourceId ? String(resourceId.value) : '',
        content: String(content.value),
        tags: tagsField && Array.isArray(tagsField.value) ? tagsField.value as string[] : [],
        createdAt: createdField ? Number(createdField.value) : 0,
        updatedAt: updatedField ? Number(updatedField.value) : 0
      })
    }
    return out
  }

  // ---- 远端合并：把服务器推来的状态并进本地 ----

  static mergeFavorites(entities: SyncEntity[], local: string[]): string[] {
    const off: string[] = []
    const on: string[] = []

    for (let i = 0; i < entities.length; i++) {
      const entity: SyncEntity = entities[i]
      if (entity.entityType !== 'favorite') continue
      const resourceId = entity.fields['resourceId']
      let id: string = resourceId ? String(resourceId.value) : ''
      if (id.length === 0 && entity.entityId.startsWith('fav:')) {
        id = entity.entityId.slice(4)
      }
      if (id.length === 0) continue
      const state = entity.fields['state']
      if (state && String(state.value) === 'false') {
        off.push(id)
      } else {
        on.push(id)
      }
    }

    const out: string[] = []
    for (let i = 0; i < local.length; i++) {
      const id: string = local[i]
      if (off.indexOf(id) < 0 && out.indexOf(id) < 0) out.push(id)
    }
    for (let i = 0; i < on.length; i++) {
      if (out.indexOf(on[i]) < 0) out.push(on[i])
    }
    return out
  }

  // 同一条笔记两边都有时，取 updatedAt 更新的那个；远端墓碑则删掉本地。
  static mergeNotes(entities: SyncEntity[], local: NoteRecord[]): NoteRecord[] {
    const removed: string[] = []
    const remote: NoteRecord[] = []

    for (let i = 0; i < entities.length; i++) {
      const entity: SyncEntity = entities[i]
      if (entity.entityType !== 'note') continue
      const noteId: string = entity.entityId.startsWith('note:')
        ? entity.entityId.slice(5)
        : entity.entityId
      const deletedFlag = entity.fields['deleted']
      if (deletedFlag && String(deletedFlag.value) === 'true') {
        removed.push(noteId)
        continue
      }
      const content = entity.fields['content']
      if (!content) continue
      const resourceId = entity.fields['resourceId']
      const tagsField = entity.fields['tags']
      const createdField = entity.fields['createdAt']
      const updatedField = entity.fields['updatedAt']
      remote.push({
        id: noteId,
        resourceId: resourceId ? String(resourceId.value) : '',
        content: String(content.value),
        tags: tagsField && Array.isArray(tagsField.value) ? tagsField.value as string[] : [],
        createdAt: createdField ? Number(createdField.value) : 0,
        updatedAt: updatedField ? Number(updatedField.value) : 0
      })
    }

    const out: NoteRecord[] = []
    for (let i = 0; i < local.length; i++) {
      const note: NoteRecord = local[i]
      if (removed.indexOf(note.id) >= 0) continue
      const match: number = CloudSyncService.indexOfNote(remote, note.id)
      if (match < 0) {
        out.push(note)
      } else {
        out.push(remote[match].updatedAt >= note.updatedAt ? remote[match] : note)
      }
    }
    for (let i = 0; i < remote.length; i++) {
      if (CloudSyncService.indexOfNote(out, remote[i].id) < 0) out.push(remote[i])
    }
    return out
  }

  private static indexOfNote(list: NoteRecord[], id: string): number {
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === id) return i
    }
    return -1
  }

  // 实时通道：服务器合并后会把新状态推给所有在线设备。
  // 断线自己重连（指数退避），重连成功后回调 onOpen，让上层补拉漏掉的变更。
  static openLive(
    accountId: string,
    deviceId: string,
    onEvent: (event: string, payload: Object) => void,
    onOpen?: () => void
  ): void {
    CloudSyncService.closeLive()
    CloudSyncService.liveAccountId = accountId
    CloudSyncService.liveDeviceId = deviceId
    CloudSyncService.liveOnEvent = onEvent
    CloudSyncService.liveOnOpen = onOpen ? onOpen : () => {}
    CloudSyncService.intentionallyClosed = false
    CloudSyncService.reconnectAttempts = 0
    CloudSyncService.connectLive()
  }

  static isLiveReady(): boolean {
    return CloudSyncService.liveReady
  }

  private static connectLive(): void {
    const accountId: string = CloudSyncService.liveAccountId
    const deviceId: string = CloudSyncService.liveDeviceId
    if (accountId.length === 0) return

    const socket: webSocket.WebSocket = webSocket.createWebSocket()
    CloudSyncService.socket = socket

    socket.on('open', () => {
      if (CloudSyncService.socket !== socket) return
      CloudSyncService.liveReady = true
      CloudSyncService.reconnectAttempts = 0
      CloudSyncService.lastServerFrameAt = Date.now()
      console.info('[CloudSync] live channel open')
      CloudSyncService.startHeartbeat()
      try {
        CloudSyncService.liveOnOpen()
      } catch (e) {
        console.error('[CloudSync] onOpen handler failed: ' + JSON.stringify(e))
      }
    })

    socket.on('message', (err: BusinessError, value: string | ArrayBuffer) => {
      if (err || typeof value !== 'string') return
      if (CloudSyncService.socket !== socket) return
      CloudSyncService.lastServerFrameAt = Date.now()
      try {
        const envelope = JSON.parse(value) as SyncEnvelope
        if (envelope.event === 'pong') return
        CloudSyncService.liveOnEvent(envelope.event, envelope.payload)
      } catch (e) {
        console.error('[CloudSync] bad frame: ' + JSON.stringify(e))
      }
    })

    socket.on('close', () => {
      if (CloudSyncService.socket !== socket) return
      console.info('[CloudSync] live channel closed')
      CloudSyncService.handleDisconnect()
    })

    socket.on('error', (err: BusinessError) => {
      if (CloudSyncService.socket !== socket) return
      console.error('[CloudSync] live channel error: ' + JSON.stringify(err))
      CloudSyncService.handleDisconnect()
    })

    const wsBase: string = CloudSyncService.baseUrl.replace('https://', 'wss://').replace('http://', 'ws://')
    const url: string = wsBase + '/ws?accountId=' + encodeURIComponent(accountId)
      + '&deviceId=' + encodeURIComponent(deviceId)
      + '&token=' + encodeURIComponent(CloudSyncService.token)
    socket.connect(url, (err: BusinessError) => {
      if (err) {
        if (CloudSyncService.socket !== socket) return
        console.error('[CloudSync] connect failed: ' + JSON.stringify(err))
        CloudSyncService.handleDisconnect()
      }
    })
  }

  private static handleDisconnect(): void {
    CloudSyncService.stopHeartbeat()
    CloudSyncService.liveReady = false
    if (CloudSyncService.intentionallyClosed) return
    if (CloudSyncService.reconnectTimer >= 0) return
    CloudSyncService.reconnectAttempts = CloudSyncService.reconnectAttempts + 1
    const delay: number = Math.min(1000 * Math.pow(2, CloudSyncService.reconnectAttempts - 1), 30000)
    console.info('[CloudSync] reconnect scheduled in ' + delay + 'ms')
    CloudSyncService.reconnectTimer = setTimeout(() => {
      CloudSyncService.reconnectTimer = -1
      if (CloudSyncService.intentionallyClosed) return
      CloudSyncService.detachSocket()
      CloudSyncService.connectLive()
    }, delay)
  }

  // 心跳：25s 发一次应用层 ping，服务端会回 pong。
  // 75s 收不到任何下行就判定连接已死，主动重连，避免"连着但收不到推送"。
  private static startHeartbeat(): void {
    CloudSyncService.stopHeartbeat()
    CloudSyncService.heartbeatTimer = setInterval(() => {
      const socket: webSocket.WebSocket | null = CloudSyncService.socket
      if (socket === null) return
      if (Date.now() - CloudSyncService.lastServerFrameAt > 75000) {
        console.warn('[CloudSync] heartbeat timeout, reconnecting')
        CloudSyncService.detachSocket()
        CloudSyncService.reconnectAttempts = 0
        CloudSyncService.connectLive()
        return
      }
      socket.send('ping', (err: BusinessError) => {
        if (err) {
          console.error('[CloudSync] heartbeat send failed: ' + JSON.stringify(err))
          CloudSyncService.handleDisconnect()
        }
      })
    }, 25000)
  }

  private static stopHeartbeat(): void {
    if (CloudSyncService.heartbeatTimer >= 0) {
      clearInterval(CloudSyncService.heartbeatTimer)
      CloudSyncService.heartbeatTimer = -1
    }
  }

  // 先摘掉引用再关闭，旧连接的回调就认不出自己、不会再触发重连
  private static detachSocket(): void {
    const socket: webSocket.WebSocket | null = CloudSyncService.socket
    CloudSyncService.socket = null
    CloudSyncService.liveReady = false
    CloudSyncService.stopHeartbeat()
    if (socket !== null) {
      try {
        socket.close()
      } catch (e) {
        console.info('[CloudSync] socket already closed')
      }
    }
  }

  static closeLive(): void {
    CloudSyncService.intentionallyClosed = true
    if (CloudSyncService.reconnectTimer >= 0) {
      clearTimeout(CloudSyncService.reconnectTimer)
      CloudSyncService.reconnectTimer = -1
    }
    CloudSyncService.detachSocket()
    CloudSyncService.liveAccountId = ''
    CloudSyncService.liveDeviceId = ''
    CloudSyncService.liveOnEvent = () => {}
    CloudSyncService.liveOnOpen = () => {}
    CloudSyncService.reconnectAttempts = 0
  }
}
