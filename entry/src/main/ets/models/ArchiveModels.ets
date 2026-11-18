export interface ArchiveItem {
  id: string
  title: string
  city: string
  era: string
  type: string
  period: string
  summary: string
  color: string
  tags: string[]
  discoveries: string[]
  poems: string[]
  travel: string
}

export interface MapSiteEntry {
  id: string
  name: string
  city: string
  era: string
  type: string
  xRatio: number
  yRatio: number
  color: string
  focus: boolean
}

export interface SiteNode {
  id: string
  name: string
  city: string
  era: string
  type: string
  x: number
  y: number
  color: string
}

export interface FavoriteRecord {
  resourceId: string
  createdAt: number
}

export interface NoteRecord {
  id: string
  resourceId: string
  content: string
  tags: string[]
  createdAt: number
  updatedAt: number
}

export interface FieldVersion<T> {
  value: T
  updatedAt: number
  deviceId: string
  version: number
}

export interface SyncEntity {
  entityId: string
  entityType: 'favorite' | 'note' | 'theme' | 'relation'
  fields: Record<string, FieldVersion<Object>>
}
