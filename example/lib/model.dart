class Model {
  String createdAt;
  String publishedAt;
  int comments;
  String url;
  bool rewardable;
  String parentComments;
  String siteId;
  String type;
  String passedTime;
  int favorites;
  int shares;
  String authorId;
  String recomType;
  bool update;
  int views;
  Site site;
  List<Images> images;
  List<String> eventTags;
  List<String> tags;
  String content;
  String excerpt;
  bool delete;
  bool collected;
  String rqtId;
  bool isFavorite;
  int imageCount;
  String dataType;
  String title;
  int postId;
  String rewards;

  Model(
      {this.createdAt,
      this.publishedAt,
      this.comments,
      this.url,
      this.rewardable,
      this.parentComments,
      this.siteId,
      this.type,
      this.passedTime,
      this.favorites,
      this.shares,
      this.authorId,
      this.recomType,
      this.update,
      this.views,
      this.site,
      this.images,
      this.eventTags,
      this.tags,
      this.content,
      this.excerpt,
      this.delete,
      this.collected,
      this.rqtId,
      this.isFavorite,
      this.imageCount,
      this.dataType,
      this.title,
      this.postId,
      this.rewards});

  Model.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    publishedAt = json['published_at'];
    comments = json['comments'];
    url = json['url'];
    rewardable = json['rewardable'];
    parentComments = json['parent_comments'];
    siteId = json['site_id'];
    type = json['type'];
    passedTime = json['passed_time'];
    favorites = json['favorites'];
    shares = json['shares'];
    authorId = json['author_id'];
    recomType = json['recom_type'];
    update = json['update'];
    views = json['views'];
    site = json['site'] != null ? new Site.fromJson(json['site']) : null;
    if (json['images'] != null) {
      images = new List<Images>();
      json['images'].forEach((v) {
        images.add(new Images.fromJson(v));
      });
    }
    eventTags = json['event_tags'].cast<String>();
    tags = json['tags'].cast<String>();
    content = json['content'];
    excerpt = json['excerpt'];
    delete = json['delete'];
    collected = json['collected'];
    rqtId = json['rqt_id'];
    isFavorite = json['is_favorite'];
    imageCount = json['image_count'];
    dataType = json['data_type'];
    title = json['title'];
    postId = json['post_id'];
    rewards = json['rewards'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.createdAt;
    data['published_at'] = this.publishedAt;
    data['comments'] = this.comments;
    data['url'] = this.url;
    data['rewardable'] = this.rewardable;
    data['parent_comments'] = this.parentComments;
    data['site_id'] = this.siteId;
    data['type'] = this.type;
    data['passed_time'] = this.passedTime;
    data['favorites'] = this.favorites;
    data['shares'] = this.shares;
    data['author_id'] = this.authorId;
    data['recom_type'] = this.recomType;
    data['update'] = this.update;
    data['views'] = this.views;
    if (this.site != null) {
      data['site'] = this.site.toJson();
    }
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    data['event_tags'] = this.eventTags;
    data['tags'] = this.tags;
    data['content'] = this.content;
    data['excerpt'] = this.excerpt;
    data['delete'] = this.delete;
    data['collected'] = this.collected;
    data['rqt_id'] = this.rqtId;
    data['is_favorite'] = this.isFavorite;
    data['image_count'] = this.imageCount;
    data['data_type'] = this.dataType;
    data['title'] = this.title;
    data['post_id'] = this.postId;
    data['rewards'] = this.rewards;
    return data;
  }
}

class Site {
  String description;
  int verifiedType;
  bool isBindEverphoto;
  int verifications;
  bool verified;
  String domain;
  String url;
  String type;
  String verifiedReason;
  bool isFollowing;
  String icon;
  int followers;
  String siteId;
  String name;
  bool hasEverphotoNote;

  Site(
      {this.description,
      this.verifiedType,
      this.isBindEverphoto,
      this.verifications,
      this.verified,
      this.domain,
      this.url,
      this.type,
      this.verifiedReason,
      this.isFollowing,
      this.icon,
      this.followers,
      this.siteId,
      this.name,
      this.hasEverphotoNote});

  Site.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    verifiedType = json['verified_type'];
    isBindEverphoto = json['is_bind_everphoto'];
    verifications = json['verifications'];
    verified = json['verified'];
    domain = json['domain'];
    url = json['url'];
    type = json['type'];
    verifiedReason = json['verified_reason'];
    isFollowing = json['is_following'];
    icon = json['icon'];
    followers = json['followers'];
    siteId = json['site_id'];
    name = json['name'];
    hasEverphotoNote = json['has_everphoto_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['verified_type'] = this.verifiedType;
    data['is_bind_everphoto'] = this.isBindEverphoto;
    data['verifications'] = this.verifications;
    data['verified'] = this.verified;
    data['domain'] = this.domain;
    data['url'] = this.url;
    data['type'] = this.type;
    data['verified_reason'] = this.verifiedReason;
    data['is_following'] = this.isFollowing;
    data['icon'] = this.icon;
    data['followers'] = this.followers;
    data['site_id'] = this.siteId;
    data['name'] = this.name;
    data['has_everphoto_note'] = this.hasEverphotoNote;
    return data;
  }
}

class Images {
  int imgId;
  String excerpt;
  int height;
  String title;
  int width;
  int userId;
  String description;

  Images(
      {this.imgId,
      this.excerpt,
      this.height,
      this.title,
      this.width,
      this.userId,
      this.description});

  Images.fromJson(Map<String, dynamic> json) {
    imgId = json['img_id'];
    excerpt = json['excerpt'];
    height = json['height'];
    title = json['title'];
    width = json['width'];
    userId = json['user_id'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['img_id'] = this.imgId;
    data['excerpt'] = this.excerpt;
    data['height'] = this.height;
    data['title'] = this.title;
    data['width'] = this.width;
    data['user_id'] = this.userId;
    data['description'] = this.description;
    return data;
  }
}
