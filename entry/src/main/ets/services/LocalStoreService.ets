import { preferences } from '@kit.ArkData'
import { FavoriteRecord, NoteRecord } from '../models/ArchiveModels'

const FAV_STORE = 'YellowRiverMemFavStore'
const NOTE_STORE = 'YellowRiverMemNoteStore'
const ACCOUNT_STORE = 'YellowRiverMemAccountStore'

export class LocalStoreService {
  private static favPrefs: preferences.Preferences | null = null
  private static notePrefs: preferences.Preferences | null = null
  private static accountPrefs: preferences.Preferences | null = null

  static init(context: Context): void {
    LocalStoreService.favPrefs = preferences.getPreferencesSync(context, { name: FAV_STORE })
    LocalStoreService.notePrefs = preferences.getPreferencesSync(context, { name: NOTE_STORE })
    LocalStoreService.accountPrefs = preferences.getPreferencesSync(context, { name: ACCOUNT_STORE })
  }

  static getFavorites(): string[] {
    if (!LocalStoreService.favPrefs) return []
    let val = LocalStoreService.favPrefs.getSync('favorites', '[]') as string
    try { return JSON.parse(val) as string[] } catch (e) { return [] }
  }

  static saveFavorites(ids: string[]): void {
    if (!LocalStoreService.favPrefs) return
    LocalStoreService.favPrefs.putSync('favorites', JSON.stringify(ids))
    LocalStoreService.favPrefs.flushSync()
  }

  static getNotes(): NoteRecord[] {
    if (!LocalStoreService.notePrefs) return []
    let val = LocalStoreService.notePrefs.getSync('notes', '[]') as string
    try { return JSON.parse(val) as NoteRecord[] } catch (e) { return [] }
  }

  static saveNotes(notes: NoteRecord[]): void {
    if (!LocalStoreService.notePrefs) return
    LocalStoreService.notePrefs.putSync('notes', JSON.stringify(notes))
    LocalStoreService.notePrefs.flushSync()
  }

  static addNote(note: NoteRecord): NoteRecord[] {
    let notes = LocalStoreService.getNotes()
    notes.unshift(note)
    LocalStoreService.saveNotes(notes)
    return notes
  }

  static getAccountId(): string {
    if (!LocalStoreService.accountPrefs) return ''
    return LocalStoreService.accountPrefs.getSync('accountId', '') as string
  }

  static saveAccountId(accountId: string): void {
    if (!LocalStoreService.accountPrefs) return
    LocalStoreService.accountPrefs.putSync('accountId', accountId)
    LocalStoreService.accountPrefs.flushSync()
  }

  static clearAccountId(): void {
    if (!LocalStoreService.accountPrefs) return
    LocalStoreService.accountPrefs.deleteSync('accountId')
    LocalStoreService.accountPrefs.flushSync()
  }

  // 同步用的账号键：使用应用自己的账号，不依赖华为账号。
  static accountKey(): string {
    let accountId: string = LocalStoreService.getAccountId()
    return accountId.length > 0 ? accountId : 'demo-account'
  }

  // 冲突裁决要靠 deviceId 分胜负，所以每台设备必须有一个稳定的标识，
  // 不能每次同步都现生成。
  static getDeviceId(): string {
    if (!LocalStoreService.accountPrefs) return ''
    return LocalStoreService.accountPrefs.getSync('deviceId', '') as string
  }

  static saveDeviceId(deviceId: string): void {
    if (!LocalStoreService.accountPrefs) return
    LocalStoreService.accountPrefs.putSync('deviceId', deviceId)
    LocalStoreService.accountPrefs.flushSync()
  }

  static ensureDeviceId(): string {
    let id: string = LocalStoreService.getDeviceId()
    if (id.length > 0) return id
    id = 'device-' + Date.now().toString(36) + '-' + Math.floor(Math.random() * 46656).toString(36)
    LocalStoreService.saveDeviceId(id)
    return id
  }
}
