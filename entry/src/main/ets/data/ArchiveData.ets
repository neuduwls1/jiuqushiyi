import { ArchiveItem, MapSiteEntry } from '../models/ArchiveModels'

export const ARCHIVE_ITEMS: ArchiveItem[] = [
  {
    id: 'yangshao',
    title: '仰韶村遗址',
    city: '三门峡',
    era: '夏以前',
    type: '聚落遗址',
    period: '约前5000—前3000年',
    summary: '中国现代考古学的重要起点，以彩陶和聚落遗存勾勒黄河先民的生活图景。',
    color: '#B34A38',
    tags: ['仰韶', '彩陶', '考古学开端'],
    discoveries: [
      '1921年安特生首次发掘，命名"仰韶文化"',
      '出土大量彩陶器，以红陶黑彩为特征',
      '发现半地穴式房址和窖穴遗迹',
      '确认粟作农业与家畜饲养的经济形态'
    ],
    poems: ['黄河九曲入中州，彩陶纹里看春秋。'],
    travel: '渑池县城北，连霍高速可达，设仰韶文化博物馆。'
  },
  {
    id: 'erlitou',
    title: '二里头遗址',
    city: '洛阳',
    era: '夏商',
    type: '都城遗址',
    period: '约前1750—前1530年',
    summary: '大型宫殿区、青铜作坊和城市主干道共同构成探索夏代晚期国家的核心证据。',
    color: '#347D73',
    tags: ['都城', '青铜', '夏代都城'],
    discoveries: [
      '中国最早的城市主干道网和宫城城墙',
      '一号宫殿基址面积约1万平方米',
      '出土中国最早的青铜礼器群',
      '绿松石龙形器长约64.5厘米，工艺精湛'
    ],
    poems: ['斟鄩故地夏都寻，绿松石龙证古今。'],
    travel: '洛阳市偃师区，二里头夏都遗址博物馆已开放。'
  },
  {
    id: 'shangcheng',
    title: '郑州商城遗址',
    city: '郑州',
    era: '夏商',
    type: '都城遗址',
    period: '约前1600—前1400年',
    summary: '规模宏大的夯土城垣与青铜铸造遗存，珍藏着商代早期都邑的城市记忆。',
    color: '#4C7468',
    tags: ['都城', '青铜', '亳都'],
    discoveries: [
      '城垣周长约7公里，为商代早期最大城址',
      '发现大型青铜铸造作坊遗址',
      '出土杜岭方鼎等王室重器',
      '确认商代早期都城"亳"的位置'
    ],
    poems: ['夯土高墙记亳都，方鼎重器镇中土。'],
    travel: '郑州市区，城东路与商城路交叉口可见城墙遗址。'
  },
  {
    id: 'yin',
    title: '殷墟',
    city: '安阳',
    era: '夏商',
    type: '都城遗址',
    period: '约前1300—前1046年',
    summary: '甲骨文、青铜礼器与宫殿王陵让商王朝从文献传说走入可实证的考古世界。',
    color: '#396B67',
    tags: ['都城', '青铜', '世界遗产'],
    discoveries: [
      '出土约15万片甲骨，发现中国最早成系统的文字',
      '妇好墓出土青铜器468件、玉器755件',
      '发现宫殿区和王陵区的大型建筑基址',
      '司母戊鼎为迄今最重的青铜器'
    ],
    poems: ['甲骨惊天下，殷墟证商朝。'],
    travel: '安阳市殷都区，殷墟博物院是世界文化遗产。'
  },
  {
    id: 'longmen',
    title: '龙门石窟',
    city: '洛阳',
    era: '汉唐',
    type: '石窟寺',
    period: '北魏至唐',
    summary: '伊河两岸的窟龛与造像记录了佛教艺术在河洛地区的长期演变。',
    color: '#B45A43',
    tags: ['世界遗产', '石刻', '佛教'],
    discoveries: [
      '现存窟龛2345个，造像10万余尊',
      '奉先寺卢舍那大佛高17.14米',
      '北魏至唐代持续营造400余年',
      '碑刻题记2800余品，为重要史料'
    ],
    poems: ['伊水两岸石窟开，十万佛像望尘埃。'],
    travel: '洛阳市洛龙区龙门镇，高铁龙门站下车即达。'
  },
  {
    id: 'baimasi',
    title: '白马寺',
    city: '洛阳',
    era: '汉唐',
    type: '古建筑',
    period: '始建于东汉永平十一年',
    summary: '中国佛教重要祖庭，寺院格局见证了丝绸之路上的文明交流。',
    color: '#6C627A',
    tags: ['佛教', '古建筑', '东汉'],
    discoveries: [
      '东汉永平十一年敕建，为中国第一座官办寺院',
      '摄摩腾、竺法兰在此译出《四十二章经》',
      '现存建筑多为明清重修',
      '寺内保存元代夹纻干漆造像'
    ],
    poems: ['白马驮经入洛阳，祖庭钟声千年长。'],
    travel: '洛阳市瀍河区白马寺镇，多路公交可达。'
  },
  {
    id: 'zhouqiao',
    title: '州桥及汴河遗址',
    city: '开封',
    era: '宋',
    type: '城市遗址',
    period: '北宋至明清',
    summary: '北宋东京城中轴线上的重要节点，石壁浮雕与河道遗存重现汴河城市景观。',
    color: '#58798D',
    tags: ['北宋', '城市考古', '东京'],
    discoveries: [
      '州桥为北宋御街与汴河交汇处的石桥',
      '石壁浮雕海马水兽纹极为精美',
      '汴河故道揭示宋代漕运体系',
      '桥址地层叠压反映开封"城摞城"奇观'
    ],
    poems: ['州桥明月汴河舟，东京梦华石壁留。'],
    travel: '开封市鼓楼区中山路地下，可参观考古现场。'
  },
  {
    id: 'tieta',
    title: '开宝寺塔',
    city: '开封',
    era: '宋',
    type: '古建筑',
    period: '北宋皇祐元年',
    summary: '八角十三层琉璃砖塔历经水患与地震仍屹立，是开封最醒目的城市记忆。',
    color: '#718892',
    tags: ['北宋', '古建筑', '东京'],
    discoveries: [
      '塔高55.88米，八角十三层楼阁式',
      '外壁镶嵌琉璃砖雕佛像、飞天等',
      '历经37次地震、18次洪水仍屹立',
      '宋代建筑技术"铁色琉璃"的杰出代表'
    ],
    poems: ['铁色琉璃十三层，阅尽黄河水与风。'],
    travel: '开封市顺河区，开封铁塔公园内。'
  },
  {
    id: 'miaodigou',
    title: '庙底沟遗址',
    city: '三门峡',
    era: '夏以前',
    type: '聚落遗址',
    period: '约前4000—前3000年',
    summary: '庙底沟类型彩陶以花瓣纹和回旋纹广泛传播，是史前文化交流与融合的重要标识。',
    color: '#B85B3D',
    tags: ['仰韶', '彩陶', '文化融合'],
    discoveries: [
      '发现仰韶文化与龙山文化连续地层',
      '出土花瓣纹、回旋勾连纹彩陶',
      '聚落房址反映农业社会组织'
    ],
    poems: ['九曲黄河万里沙，浪淘风簸自天涯。'],
    travel: '三门峡市湖滨区庙底沟考古遗址公园。'
  },
  {
    id: 'yanshi-shang',
    title: '偃师商城遗址',
    city: '洛阳',
    era: '夏商',
    type: '都城遗址',
    period: '约公元前1600年',
    summary: '宫城、小城和大城三重城垣记录了商代早期都城的城市规划与国家治理。',
    color: '#4F7469',
    tags: ['都城', '青铜', '商代早期'],
    discoveries: [
      '确认宫城、小城和大城重叠的城垣格局',
      '发现宫殿建筑与祭祀遗存',
      '为夏商分界研究提供关键材料'
    ],
    poems: ['商邑翼翼，四方之极。'],
    travel: '洛阳市偃师区，可结合二里头遗址同线参观。'
  },
  {
    id: 'dahecun',
    title: '大河村遗址',
    city: '郑州',
    era: '夏以前',
    type: '聚落遗址',
    period: '约前5000—前3000年',
    summary: '保存较好的连间房屋基址和星空彩陶，为理解中原史前聚落生活提供鲜活材料。',
    color: '#607D6B',
    tags: ['仰韶', '彩陶', '聚落'],
    discoveries: [
      '发现地面式连间房屋基址',
      '彩陶出现太阳纹、月亮纹和星座纹',
      '遗存延续仰韶至龙山时期'
    ],
    poems: ['天回北斗挂西楼，金屋无人萤火流。'],
    travel: '郑州市金水区大河村遗址博物馆。'
  },
  {
    id: 'hanwei-luoyang',
    title: '汉魏洛阳城',
    city: '洛阳',
    era: '汉唐',
    type: '都城遗址',
    period: '东汉至北魏',
    summary: '汉魏洛阳城长期作为王朝都城，宫城、太极殿和中轴格局影响后世都城制度。',
    color: '#6C627A',
    tags: ['都城', '汉魏', '城市中轴'],
    discoveries: [
      '发现宫城与太极殿等重要建筑基址',
      '城市中轴线延续至隋唐洛阳城',
      '文化遗存跨越东汉、曹魏、西晋和北魏'
    ],
    poems: ['洛都四郊，山水之胜，龙门首焉。'],
    travel: '洛阳市洛龙区与偃师区交界，可与白马寺联动游览。'
  },
  {
    id: 'gongyi-grotto',
    title: '巩义石窟',
    city: '郑州',
    era: '汉唐',
    type: '石窟寺',
    period: '北魏',
    summary: '巩义石窟规模不大，却保存了北魏皇家石窟艺术的重要实例，飞天与帝后礼佛图尤为珍贵。',
    color: '#B45A43',
    tags: ['石刻', '佛教', '北魏'],
    discoveries: [
      '保存北魏时期的中心塔柱窟',
      '帝后礼佛图构图完整',
      '飞天与伎乐雕刻具有高度艺术价值'
    ],
    poems: ['伊洛清波映石龛，千年造像见庄严。'],
    travel: '郑州市巩义市河洛镇，建议自驾前往。'
  },
  {
    id: 'songling',
    title: '北宋皇陵',
    city: '郑州',
    era: '宋',
    type: '墓葬群',
    period: '北宋',
    summary: '七帝八陵与后妃宗室墓葬构成巨大陵区，神道石刻体现宋代礼制、艺术和山河格局。',
    color: '#68747A',
    tags: ['北宋', '帝陵', '石刻'],
    discoveries: [
      '陵区依嵩山、洛水布局',
      '神道保存大量石人与石兽',
      '陵台、阙台呈现宋代帝陵制度'
    ],
    poems: ['青山如浪入漳州，铜雀台西八九丘。'],
    travel: '郑州市巩义市，各陵分布较广，建议自驾规划线路。'
  },
  {
    id: 'xishuipo',
    title: '西水坡遗址',
    city: '濮阳',
    era: '夏以前',
    type: '墓葬群',
    period: '约前4500年',
    summary: '蚌塑龙虎图案和高等级墓葬让西水坡成为研究早期精神世界与天文观念的重要遗址。',
    color: '#365F63',
    tags: ['仰韶', '龙文化', '墓葬'],
    discoveries: [
      '发现蚌壳摆塑的龙虎图案',
      '高等级墓葬反映复杂社会关系',
      '部分学者将蚌塑方位与古代天文观念联系'
    ],
    poems: ['黄河之水天上来，奔流到海不复回。'],
    travel: '濮阳市濮阳县，可结合濮阳博物馆参观。'
  },
  {
    id: 'huangye-kiln',
    title: '黄冶三彩窑址',
    city: '郑州',
    era: '汉唐',
    type: '窑址',
    period: '隋唐',
    summary: '巩义黄冶窑是唐三彩的重要产地，窑炉、作坊和器物残片见证唐代窑业与丝路贸易。',
    color: '#9D5D42',
    tags: ['唐三彩', '窑址', '丝路'],
    discoveries: [
      '发现窑炉、作坊和澄泥池',
      '出土黄、绿、白及蓝彩器物',
      '产品沿丝绸之路传播至远方'
    ],
    poems: ['九秋风露越窑开，夺得千峰翠色来。'],
    travel: '郑州市巩义市黄冶村，建议与巩义博物馆组合游览。'
  },
  {
    id: 'qicheng',
    title: '戚城遗址',
    city: '濮阳',
    era: '周',
    type: '都城遗址',
    period: '春秋',
    summary: '戚城是春秋时期卫国重要城邑，城垣、会盟台遗存记录了诸侯会盟与中原政治格局。',
    color: '#396B67',
    tags: ['春秋', '古城', '诸侯会盟'],
    discoveries: [
      '保存东周城垣与城址格局',
      '发现与诸侯会盟相关的文化遗存',
      '遗址公园展示濮阳早期城市历史'
    ],
    poems: ['卫水悠悠绕古城，会盟台畔说春秋。'],
    travel: '濮阳市华龙区戚城文物景区。'
  },
  {
    id: 'dongzhou-wangcheng',
    title: '东周王城遗址',
    city: '洛阳',
    era: '周',
    type: '都城遗址',
    period: '东周',
    summary: '东周王室在洛阳的城址遗存，王城格局与“天子驾六”车马坑见证周代礼制与城市制度。',
    color: '#6C627A',
    tags: ['东周', '王城', '天子驾六'],
    discoveries: [
      '发现东周王城城墙与城门遗迹',
      "出土“天子驾六”车马坑",
      '城址布局反映周代都城礼制'
    ],
    poems: ['王城东周问鼎迁，车马煌煌礼乐传。'],
    travel: '洛阳市王城公园一带，可结合洛阳博物馆参观。'
  },
  {
    id: 'suiyang-luoyang',
    title: '隋唐洛阳城定鼎门遗址',
    city: '洛阳',
    era: '汉唐',
    type: '城市遗址',
    period: '隋至宋',
    summary: '隋唐洛阳城的天街与定鼎门是中轴线与里坊制度的见证，也被列入丝绸之路世界遗产。',
    color: '#315E78',
    tags: ['中轴', '里坊', '丝路起点'],
    discoveries: [
      '定鼎门为隋唐洛阳城外郭城正南门',
      '天街、里坊格局保存较为清晰',
      '列入丝绸之路世界文化遗产'
    ],
    poems: ['定鼎门前天街远，隋唐气象入中州。'],
    travel: '洛阳市洛龙区，洛阳博物馆隋唐展可联动参观。'
  },
  {
    id: 'youlicheng',
    title: '羑里城遗址',
    city: '安阳',
    era: '周',
    type: '古城遗址',
    period: '商周之际',
    summary: '相传为文王演易之地，城墙与八卦阵展示处所连接了考古遗存与易学传统。',
    color: '#8C6A4A',
    tags: ['周易', '文王演易', '商周之际'],
    discoveries: [
      '发现商周之际城墙与夯土基址',
      '遗址展示区结合八卦文化进行阐释',
      '是研究易学传统与城址结合的重要节点'
    ],
    poems: ['羑里城中演易经，斯文一线接商周。'],
    travel: '安阳市汤阴县，可结合岳飞庙组成文化线路。'
  },
  {
    id: 'hanjiaguan',
    title: '汉函谷关与崤函古道',
    city: '三门峡',
    era: '汉唐',
    type: '关隘遗址',
    period: '汉至唐',
    summary: '中原通往关西的要隘，关楼、古道与碑刻共同保存了丝绸之路东段的交通与关隘制度。',
    color: '#244D6A',
    tags: ['丝绸之路', '关隘', '古道'],
    discoveries: [
      '关隘遗址保存汉代至唐代交通格局',
      '古道遗存可辨识车辙与马蹄痕迹',
      '碑刻记录关防制度与商旅往来'
    ],
    poems: ['崤函古道西连秦，函谷秋风说汉关。'],
    travel: '三门峡市灵宝市，建议与函谷关历史文化旅游区同游。'
  },
  {
    id: 'jiahu',
    title: '贾湖遗址',
    city: '漯河',
    era: '夏以前',
    type: '聚落遗址',
    period: '约前9000—前7500年',
    summary: '淮河流域重要的新石器早期遗址，骨笛、稻作遗存和早期刻符都与文明起源密切相关。',
    color: '#A05A3C',
    tags: ['新石器早期', '骨笛', '稻作'],
    discoveries: [
      '出土多支骨笛，可吹奏七声音阶',
      '发现水稻遗存，为稻作北传研究提供材料',
      '龟甲和骨器上发现早期刻符'
    ],
    poems: ['贾湖骨笛惊千古，稻作遗存说早春。'],
    travel: '漯河市舞阳县，可结合贾湖遗址公园参观。'
  },
  {
    id: 'huaiyang-pingliangtai',
    title: '淮阳平粮台古城遗址',
    city: '周口',
    era: '夏以前',
    type: '城址',
    period: '约前2000年',
    summary: '龙山晚期方形城址与陶制排水管道保存较完整，堪称早期城市规划的重要实证。',
    color: '#7A6B6A',
    tags: ['龙山晚期', '城址', '排水系统'],
    discoveries: [
      '发现规整方形城墙与城门',
      '城内出土陶质排水管道',
      '城址格局说明已有系统性规划思想'
    ],
    poems: ['平粮台畔古城方，陶管暗排水长流。'],
    travel: '周口市淮阳区，可结合淮阳太昊陵游览。'
  }
]

export const MAP_SITES: MapSiteEntry[] = [
  { id: 'yangshao', name: '仰韶村遗址', city: '三门峡市渑池县', era: '新石器·仰韶', type: '聚落遗址', xRatio: 0.085, yRatio: 0.155, color: '#B34A38', focus: true },
  { id: 'miaodigou', name: '庙底沟遗址', city: '三门峡市', era: '新石器·仰韶', type: '聚落遗址', xRatio: 0.128, yRatio: 0.178, color: '#B34A38', focus: true },
  { id: 'erlitou', name: '二里头遗址', city: '洛阳市偃师区', era: '夏', type: '都城遗址', xRatio: 0.185, yRatio: 0.152, color: '#347D73', focus: true },
  { id: 'yanshi-shang', name: '偃师商城', city: '洛阳市偃师区', era: '商', type: '都城遗址', xRatio: 0.215, yRatio: 0.130, color: '#4C7468', focus: true },
  { id: 'baimasi', name: '白马寺', city: '洛阳市', era: '东汉至今', type: '佛教寺院', xRatio: 0.248, yRatio: 0.162, color: '#6C627A', focus: true },
  { id: 'longmen', name: '龙门石窟', city: '洛阳市', era: '北魏-唐', type: '石刻艺术', xRatio: 0.265, yRatio: 0.185, color: '#B45A43', focus: true },
  { id: 'shangcheng', name: '郑州商城', city: '郑州市', era: '商', type: '都城遗址', xRatio: 0.310, yRatio: 0.195, color: '#4C7468', focus: true },
  { id: 'dahecun', name: '大河村遗址', city: '郑州市', era: '新石器-商', type: '聚落遗址', xRatio: 0.340, yRatio: 0.178, color: '#B34A38', focus: true },
  { id: 'yin', name: '殷墟', city: '安阳市', era: '商', type: '都城遗址', xRatio: 0.382, yRatio: 0.218, color: '#396B67', focus: true },
  { id: 'zhouqiao', name: '州桥及汴河遗址', city: '开封市', era: '宋', type: '水利遗址', xRatio: 0.355, yRatio: 0.238, color: '#58798D', focus: true },
  { id: 'tieta', name: '开宝寺塔', city: '开封市', era: '宋', type: '古建筑', xRatio: 0.372, yRatio: 0.252, color: '#718892', focus: true },
  { id: 'hanwei-luoyang', name: '汉魏洛阳城', city: '洛阳市', era: '汉-北魏', type: '都城遗址', xRatio: 0.228, yRatio: 0.222, color: '#6C627A', focus: true },
  { id: 'gongyi-grotto', name: '巩义石窟', city: '巩义市', era: '北魏', type: '石刻艺术', xRatio: 0.290, yRatio: 0.200, color: '#B45A43', focus: true },
  { id: 'songling', name: '北宋皇陵', city: '巩义市', era: '宋', type: '帝王陵墓', xRatio: 0.305, yRatio: 0.268, color: '#58798D', focus: true },
  { id: 'xishuipo', name: '西水坡遗址', city: '濮阳市', era: '新石器·仰韶', type: '聚落遗址', xRatio: 0.452, yRatio: 0.258, color: '#B34A38', focus: true },
  { id: 'huangye-kiln', name: '黄冶窑址', city: '巩义市', era: '唐-宋', type: '陶瓷窑址', xRatio: 0.278, yRatio: 0.235, color: '#C18B36', focus: true },
  { id: 'qicheng', name: '戚城遗址', city: '濮阳市', era: '春秋', type: '古城遗址', xRatio: 0.475, yRatio: 0.225, color: '#396B67', focus: true },
  { id: 'dongzhou-wangcheng', name: '东周王城遗址', city: '洛阳市', era: '东周', type: '都城遗址', xRatio: 0.250, yRatio: 0.255, color: '#6C627A', focus: true },
  { id: 'zhenghan-gucheng', name: '郑韩故城', city: '郑州市', era: '春秋战国', type: '都城遗址', xRatio: 0.365, yRatio: 0.270, color: '#4F7469', focus: true },
  { id: 'suiyang-luoyang', name: '隋唐洛阳城定鼎门遗址', city: '洛阳市', era: '隋-宋', type: '城市遗址', xRatio: 0.260, yRatio: 0.295, color: '#315E78', focus: true },
  { id: 'youlicheng', name: '羑里城遗址', city: '安阳市', era: '商周之际', type: '古城遗址', xRatio: 0.390, yRatio: 0.160, color: '#8C6A4A', focus: true },
  { id: 'hanjiaguan', name: '汉函谷关与崤函古道', city: '三门峡市', era: '汉-唐', type: '关隘遗址', xRatio: 0.150, yRatio: 0.200, color: '#244D6A', focus: true },
  { id: 'fanta', name: '繁塔', city: '开封市', era: '北宋', type: '古建筑', xRatio: 0.382, yRatio: 0.265, color: '#718892', focus: false },
  { id: 'yanqingguan', name: '延庆观', city: '开封市', era: '北宋', type: '古建筑', xRatio: 0.398, yRatio: 0.278, color: '#58798D', focus: false },
  { id: 'xiudingsi', name: '修定寺塔', city: '安阳市', era: '南北朝', type: '古建筑', xRatio: 0.425, yRatio: 0.195, color: '#8C6E5C', focus: false },
  { id: 'peiligang', name: '裴李岗遗址', city: '郑州市', era: '新石器时代早期', type: '聚落遗址', xRatio: 0.340, yRatio: 0.255, color: '#8B4A3A', focus: false },
  { id: 'jiahu', name: '贾湖遗址', city: '漯河市', era: '新石器时代早期', type: '聚落遗址', xRatio: 0.420, yRatio: 0.240, color: '#A05A3C', focus: true },
  { id: 'lingbao-xipo', name: '灵宝西坡遗址', city: '三门峡市', era: '新石器·仰韶', type: '聚落遗址', xRatio: 0.145, yRatio: 0.205, color: '#B45A43', focus: false },
  { id: 'dengfeng-wangchenggang', name: '登封王城岗遗址', city: '郑州市', era: '新石器时代晚期', type: '城址', xRatio: 0.350, yRatio: 0.222, color: '#9D5D42', focus: false },
  { id: 'xinmi-guchengzhai', name: '新密古城寨遗址', city: '郑州市', era: '新石器时代晚期', type: '城址', xRatio: 0.358, yRatio: 0.238, color: '#8C6E5C', focus: false },
  { id: 'huaiyang-pingliangtai', name: '淮阳平粮台古城遗址', city: '周口市', era: '新石器时代晚期', type: '城址', xRatio: 0.485, yRatio: 0.215, color: '#7A6B6A', focus: false }
]
