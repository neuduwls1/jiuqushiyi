import http from '@ohos.net.http'
import type { BusinessError } from '@ohos.base'

/**
 * 「河小忆」——黄河文化问答助手
 *
 * 只做一件事：围绕河南段黄河沿线的遗址、朝代、考古、诗词、民俗回答问题。
 * 与主题无关的、以及色情/暴力/恐怖主义等违规内容一律拒绝。
 */

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant'
  content: string
}

interface ChatChoice {
  message: ChatMessage
}

interface ApiResponse {
  choices: ChatChoice[]
}

const BASE_URL: string = 'https://api.deepseek.com'
// Never commit an AI provider key or ship one in a public client build.
// Configure a server-side proxy for production; this public source keeps the
// feature disabled until a runtime-safe credential is supplied.
const API_KEY: string = ''
const MODEL: string = 'deepseek-chat'
const MAX_HISTORY: number = 6

export const SYSTEM_PROMPT: string = `你是「河小忆」，九曲拾忆 App 里的黄河文化讲解助手，说话像一位耐心的博物馆讲解员。

【只聊这个范围】
黄河（重点是河南段）沿线的文化内容：遗址与考古发现（二里头、仰韶、殷墟、大河村等）、博物馆与文物、朝代更迭、历史人物、诗词典故、民俗与非遗、地理风物、参观与旅行建议。

【范围之外一律不展开】
编程、写作代笔、医疗诊断、法律意见、金融投资、政治评论、时事新闻、娱乐八卦等，礼貌说明"这个我可以请你看别的入口"，然后把话题引回黄河文化。

【绝对不输出】
色情或性暗示内容；暴力、血腥、伤害细节；恐怖主义、极端主义、煽动性内容；自杀自伤；违法犯罪方法；对具体人群的歧视与攻击。遇到这类提问，只回一句明确的拒绝，不解释、不举例、不提供"换个说法"的替代方案。

【怎么回答】
1. 中文口语，150 字以内，先给结论再补一句背景；
2. 史实有争议时说明"常见说法是……"，不要编造年代与数字；
3. 用户问"怎么去""值不值得去"，给具体一到两条建议即可；
4. 不主动推销商品、不推荐具体商家。`

/** 客户端兜底拦截：模型万一没守住，这里也不放行 */
const BLOCKED_WORDS: string[] = [
  '色情', '裸聊', '性行为', '做爱', '约炮', '成人视频',
  '自杀', '割腕', '自残',
  '杀人', '砍人', '虐杀', '分尸', '血腥',
  '恐怖袭击', '炸弹制作', '制毒', '吸毒', '枪支交易'
]

export class AIChatService {
  /** 命中兜底词库返回 true，调用方直接给拒绝话术，不必发请求 */
  static blocked(text: string): boolean {
    const lower: string = text.toLowerCase()
    for (let i = 0; i < BLOCKED_WORDS.length; i++) {
      if (lower.indexOf(BLOCKED_WORDS[i]) >= 0) {
        return true
      }
    }
    return false
  }

  static refusal(): string {
    return '这个问题不在我的讲解范围里，我只陪你看黄河两岸的遗址、朝代和故事。换一个文化相关的问题，我很乐意聊。'
  }

  /** 发一轮对话，返回助手回复文本 */
  static async chat(history: ChatMessage[], question: string): Promise<string> {
    if (API_KEY.length === 0) {
      throw new Error('AI service is not configured')
    }
    const apiMessages: ChatMessage[] = [{ role: 'system', content: SYSTEM_PROMPT }]
    const recent: ChatMessage[] = history.slice(-MAX_HISTORY)
    for (let i = 0; i < recent.length; i++) {
      apiMessages.push(recent[i])
    }
    apiMessages.push({ role: 'user', content: question })

    const request = http.createHttp()
    try {
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + API_KEY
        },
        extraData: JSON.stringify({ messages: apiMessages, model: MODEL, temperature: 0.7, max_tokens: 600 }),
        connectTimeout: 30000,
        readTimeout: 30000,
        expectDataType: http.HttpDataType.STRING
      }
      const response: http.HttpResponse = await request.request(BASE_URL + '/v1/chat/completions', options)
      if (response.responseCode !== 200) {
        throw new Error('接口返回 ' + response.responseCode)
      }
      const raw: string = response.result as string
      const data: ApiResponse = JSON.parse(raw) as ApiResponse
      const reply: string = data.choices[0].message.content
      return reply.trim().length > 0 ? reply.trim() : '我一时没想好怎么讲，你可以再问得具体一点。'
    } catch (error) {
      const err = error as BusinessError
      console.error('[AIChat] request failed: ' + (err && err.message ? err.message : 'unknown'))
      throw new Error('网络异常')
    } finally {
      request.destroy()
    }
  }
}
