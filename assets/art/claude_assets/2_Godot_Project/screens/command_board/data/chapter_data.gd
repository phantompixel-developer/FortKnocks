class_name ChapterData
extends Resource
## A chapter: several regions, each with several missions. Missions are numbered per chapter.

@export var number := 1
@export var title := ""
@export var regions: Array[RegionData] = []
