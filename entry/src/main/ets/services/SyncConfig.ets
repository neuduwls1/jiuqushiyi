import { preferences } from '@kit.ArkData'

/**
 * 同步服务器配置（RK3568 / OpenHarmony 版本使用）
 *
 * 这个版本不依赖华为账号：两台设备只要把「服务器地址」填成同一个值，
 * 就会读写同一份数据，实现局域网内的双端同步。
 * 地址保存在 preferences 里，卸载重装才会丢。
 */

const STORE_NAME: string = 'SyncServerStore'
// Replace with your own sync service URL before enabling cloud sync.
const DEFAULT_URL: string = ''
// Do not commit a real sync token. Configure it on the device before enabling cloud sync.
const DEFAULT_TOKEN: string = ''

export class SyncConfig {
  private static prefs: preferences.Preferences | null = null

  static init(context: Context): void {
    if (SyncConfig.prefs === null) {
      SyncConfig.prefs = preferences.getPreferencesSync(context, { name: STORE_NAME })
    }
  }

  static baseUrl(): string {
    if (SyncConfig.prefs === null) {
      return DEFAULT_URL
    }
    const value: string = SyncConfig.prefs.getSync('baseUrl', DEFAULT_URL) as string
    return SyncConfig.normalize(value.length > 0 ? value : DEFAULT_URL)
  }

  /**
   * 补全服务器地址：少了协议头补 http://，少了端口补 :8080，去掉结尾多余的斜杠。
   * 板子上手输时很容易漏掉端口，这里兜住，避免“地址看起来对、就是连不上”。
   */
  static normalize(raw: string): string {
    let url: string = raw.trim()
    if (url.length === 0) {
      return DEFAULT_URL
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://' + url
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1)
    }
    const schemeEnd: number = url.indexOf('://')
    const rest: string = url.substring(schemeEnd + 3)
    if (rest.indexOf(':') < 0) {
      url = url + ':8080'
    }
    return url
  }

  static token(): string {
    if (SyncConfig.prefs === null) {
      return DEFAULT_TOKEN
    }
    const value: string = SyncConfig.prefs.getSync('token', DEFAULT_TOKEN) as string
    return value.length > 0 ? value : DEFAULT_TOKEN
  }

  /** 保存地址并立即生效（调用方负责随后重连） */
  static save(url: string): void {
    if (SyncConfig.prefs === null) {
      return
    }
    SyncConfig.prefs.putSync('baseUrl', SyncConfig.normalize(url))
    SyncConfig.prefs.flushSync()
  }

  static saveToken(token: string): void {
    if (SyncConfig.prefs === null) {
      return
    }
    SyncConfig.prefs.putSync('token', token.trim())
    SyncConfig.prefs.flushSync()
  }
}
