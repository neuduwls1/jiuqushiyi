export interface CityLocation {
  id: string
  name: string
  address: string
  xRatio: number
  yRatio: number
  color: string
  siteIds: string[]
}

export const CITY_LOCATIONS: CityLocation[] = [
  {
    id: 'sanmenxia',
    name: '三门峡',
    address: '河南省三门峡市',
    xRatio: 0.15,
    yRatio: 0.24,
    color: '#A94736',
    siteIds: ['yangshao', 'miaodigou', 'hanjiaguan']
  },
  {
    id: 'luoyang',
    name: '洛阳',
    address: '河南省洛阳市',
    xRatio: 0.29,
    yRatio: 0.36,
    color: '#347D73',
    siteIds: ['erlitou', 'yanshi-shang', 'baimasi', 'longmen', 'hanwei-luoyang', 'dongzhou-wangcheng', 'suiyang-luoyang']
  },
  {
    id: 'zhengzhou',
    name: '郑州',
    address: '河南省郑州市及巩义市',
    xRatio: 0.48,
    yRatio: 0.42,
    color: '#4C7468',
    siteIds: ['shangcheng', 'dahecun', 'gongyi-grotto', 'songling', 'huangye-kiln', 'zhenghan-gucheng']
  },
  {
    id: 'kaifeng',
    name: '开封',
    address: '河南省开封市',
    xRatio: 0.64,
    yRatio: 0.47,
    color: '#58798D',
    siteIds: ['zhouqiao', 'tieta']
  },
  {
    id: 'anyang',
    name: '安阳',
    address: '河南省安阳市及汤阴县',
    xRatio: 0.54,
    yRatio: 0.17,
    color: '#396B67',
    siteIds: ['yin', 'youlicheng']
  },
  {
    id: 'puyang',
    name: '濮阳',
    address: '河南省濮阳市',
    xRatio: 0.77,
    yRatio: 0.26,
    color: '#B88935',
    siteIds: ['xishuipo', 'qicheng']
  },
  {
    id: 'luohe',
    name: '漯河',
    address: '河南省漯河市舞阳县',
    xRatio: 0.60,
    yRatio: 0.43,
    color: '#8C6A4A',
    siteIds: ['jiahu']
  },
  {
    id: 'zhoukou',
    name: '周口',
    address: '河南省周口市淮阳区',
    xRatio: 0.69,
    yRatio: 0.37,
    color: '#7A6B6A',
    siteIds: ['huaiyang-pingliangtai']
  }
]
