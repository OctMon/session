import 'dart:convert' show json;

class DataMode {
  bool isHistory;
  int counts;
  List<FeedList> feedList;
  String message;
  bool more;
  String result;

  DataMode({
    this.isHistory,
    this.counts,
    this.feedList,
    this.message,
    this.more,
    this.result,
  });

  static DataMode fromJson(jsonRes) {
    if (jsonRes == null) return null;

    List<FeedList> feedList = jsonRes['feedList'] is List ? [] : null;
    if (feedList != null) {
      for (var item in jsonRes['feedList']) {
        if (item != null) {
          feedList.add(FeedList.fromJson(item));
        }
      }
    }
    return DataMode(
      isHistory: jsonRes['is_history'],
      counts: jsonRes['counts'],
      feedList: feedList,
      message: jsonRes['message'],
      more: jsonRes['more'],
      result: jsonRes['result'],
    );
  }

  Map<String, dynamic> toJson() => {
        'is_history': isHistory,
        'counts': counts,
        'feedList': feedList,
        'message': message,
        'more': more,
        'result': result,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class FeedList {
  int postId;
  String type;
  String url;
  String siteId;
  String authorId;
  String publishedAt;
  String passedTime;
  String excerpt;
  int favorites;
  int comments;
  bool rewardable;
  String parentComments;
  String rewards;
  int views;
  bool collected;
  int shares;
  bool recommend;
  bool delete;
  bool update;
  String content;
  String title;
  int imageCount;
  List<Images> images;
  Object titleImage;
  List<String> tags;
  List<String> eventTags;
  List<Object> favoriteListPrefix;
  List<Object> rewardListPrefix;
  List<Object> commentListPrefix;
  String dataType;
  String createdAt;
  List<Object> sites;
  Site site;
  String recomType;
  String rqtId;
  bool isFavorite;

  FeedList({
    this.postId,
    this.type,
    this.url,
    this.siteId,
    this.authorId,
    this.publishedAt,
    this.passedTime,
    this.excerpt,
    this.favorites,
    this.comments,
    this.rewardable,
    this.parentComments,
    this.rewards,
    this.views,
    this.collected,
    this.shares,
    this.recommend,
    this.delete,
    this.update,
    this.content,
    this.title,
    this.imageCount,
    this.images,
    this.titleImage,
    this.tags,
    this.eventTags,
    this.favoriteListPrefix,
    this.rewardListPrefix,
    this.commentListPrefix,
    this.dataType,
    this.createdAt,
    this.sites,
    this.site,
    this.recomType,
    this.rqtId,
    this.isFavorite,
  });

  static FeedList fromJson(jsonRes) {
    if (jsonRes == null) return null;

    List<Images> images = jsonRes['images'] is List ? [] : null;
    if (images != null) {
      for (var item in jsonRes['images']) {
        if (item != null) {
          images.add(Images.fromJson(item));
        }
      }
    }

    List<String> tags = jsonRes['tags'] is List ? [] : null;
    if (tags != null) {
      for (var item in jsonRes['tags']) {
        if (item != null) {
          tags.add(item);
        }
      }
    }

    List<String> eventTags = jsonRes['event_tags'] is List ? [] : null;
    if (eventTags != null) {
      for (var item in jsonRes['event_tags']) {
        if (item != null) {
          eventTags.add(item);
        }
      }
    }

    List<Object> favoriteListPrefix =
        jsonRes['favorite_list_prefix'] is List ? [] : null;
    if (favoriteListPrefix != null) {
      for (var item in jsonRes['favorite_list_prefix']) {
        if (item != null) {
          favoriteListPrefix.add(item);
        }
      }
    }

    List<Object> rewardListPrefix =
        jsonRes['reward_list_prefix'] is List ? [] : null;
    if (rewardListPrefix != null) {
      for (var item in jsonRes['reward_list_prefix']) {
        if (item != null) {
          rewardListPrefix.add(item);
        }
      }
    }

    List<Object> commentListPrefix =
        jsonRes['comment_list_prefix'] is List ? [] : null;
    if (commentListPrefix != null) {
      for (var item in jsonRes['comment_list_prefix']) {
        if (item != null) {
          commentListPrefix.add(item);
        }
      }
    }

    List<Object> sites = jsonRes['sites'] is List ? [] : null;
    if (sites != null) {
      for (var item in jsonRes['sites']) {
        if (item != null) {
          sites.add(item);
        }
      }
    }
    return FeedList(
      postId: jsonRes['post_id'],
      type: jsonRes['type'],
      url: jsonRes['url'],
      siteId: jsonRes['site_id'],
      authorId: jsonRes['author_id'],
      publishedAt: jsonRes['published_at'],
      passedTime: jsonRes['passed_time'],
      excerpt: jsonRes['excerpt'],
      favorites: jsonRes['favorites'],
      comments: jsonRes['comments'],
      rewardable: jsonRes['rewardable'],
      parentComments: jsonRes['parent_comments'],
      rewards: jsonRes['rewards'],
      views: jsonRes['views'],
      collected: jsonRes['collected'],
      shares: jsonRes['shares'],
      recommend: jsonRes['recommend'],
      delete: jsonRes['delete'],
      update: jsonRes['update'],
      content: jsonRes['content'],
      title: jsonRes['title'],
      imageCount: jsonRes['image_count'],
      images: images,
      titleImage: jsonRes['title_image'],
      tags: tags,
      eventTags: eventTags,
      favoriteListPrefix: favoriteListPrefix,
      rewardListPrefix: rewardListPrefix,
      commentListPrefix: commentListPrefix,
      dataType: jsonRes['data_type'],
      createdAt: jsonRes['created_at'],
      sites: sites,
      site: Site.fromJson(jsonRes['site']),
      recomType: jsonRes['recom_type'],
      rqtId: jsonRes['rqt_id'],
      isFavorite: jsonRes['is_favorite'],
    );
  }

  Map<String, dynamic> toJson() => {
        'post_id': postId,
        'type': type,
        'url': url,
        'site_id': siteId,
        'author_id': authorId,
        'published_at': publishedAt,
        'passed_time': passedTime,
        'excerpt': excerpt,
        'favorites': favorites,
        'comments': comments,
        'rewardable': rewardable,
        'parent_comments': parentComments,
        'rewards': rewards,
        'views': views,
        'collected': collected,
        'shares': shares,
        'recommend': recommend,
        'delete': delete,
        'update': update,
        'content': content,
        'title': title,
        'image_count': imageCount,
        'images': images,
        'title_image': titleImage,
        'tags': tags,
        'event_tags': eventTags,
        'favorite_list_prefix': favoriteListPrefix,
        'reward_list_prefix': rewardListPrefix,
        'comment_list_prefix': commentListPrefix,
        'data_type': dataType,
        'created_at': createdAt,
        'sites': sites,
        'site': site,
        'recom_type': recomType,
        'rqt_id': rqtId,
        'is_favorite': isFavorite,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Images {
  int imgId;
  String imgIdStr;
  int userId;
  String title;
  String excerpt;
  int width;
  int height;
  String description;

  Images({
    this.imgId,
    this.imgIdStr,
    this.userId,
    this.title,
    this.excerpt,
    this.width,
    this.height,
    this.description,
  });

  static Images fromJson(jsonRes) => jsonRes == null
      ? null
      : Images(
          imgId: jsonRes['img_id'],
          imgIdStr: jsonRes['img_id_str'],
          userId: jsonRes['user_id'],
          title: jsonRes['title'],
          excerpt: jsonRes['excerpt'],
          width: jsonRes['width'],
          height: jsonRes['height'],
          description: jsonRes['description'],
        );

  Map<String, dynamic> toJson() => {
        'img_id': imgId,
        'img_id_str': imgIdStr,
        'user_id': userId,
        'title': title,
        'excerpt': excerpt,
        'width': width,
        'height': height,
        'description': description,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Site {
  String siteId;
  String type;
  String name;
  String domain;
  String description;
  int followers;
  String url;
  String icon;
  bool isBindEverphoto;
  bool hasEverphotoNote;
  bool verified;
  int verifications;
  List<Verification_list> verificationList;
  bool isFollowing;

  Site({
    this.siteId,
    this.type,
    this.name,
    this.domain,
    this.description,
    this.followers,
    this.url,
    this.icon,
    this.isBindEverphoto,
    this.hasEverphotoNote,
    this.verified,
    this.verifications,
    this.verificationList,
    this.isFollowing,
  });

  static Site fromJson(jsonRes) {
    if (jsonRes == null) return null;

    List<Verification_list> verificationList =
        jsonRes['verification_list'] is List ? [] : null;
    if (verificationList != null) {
      for (var item in jsonRes['verification_list']) {
        if (item != null) {
          verificationList.add(Verification_list.fromJson(item));
        }
      }
    }
    return Site(
      siteId: jsonRes['site_id'],
      type: jsonRes['type'],
      name: jsonRes['name'],
      domain: jsonRes['domain'],
      description: jsonRes['description'],
      followers: jsonRes['followers'],
      url: jsonRes['url'],
      icon: jsonRes['icon'],
      isBindEverphoto: jsonRes['is_bind_everphoto'],
      hasEverphotoNote: jsonRes['has_everphoto_note'],
      verified: jsonRes['verified'],
      verifications: jsonRes['verifications'],
      verificationList: verificationList,
      isFollowing: jsonRes['is_following'],
    );
  }

  Map<String, dynamic> toJson() => {
        'site_id': siteId,
        'type': type,
        'name': name,
        'domain': domain,
        'description': description,
        'followers': followers,
        'url': url,
        'icon': icon,
        'is_bind_everphoto': isBindEverphoto,
        'has_everphoto_note': hasEverphotoNote,
        'verified': verified,
        'verifications': verifications,
        'verification_list': verificationList,
        'is_following': isFollowing,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Verification_list {
  int verificationType;
  String verificationReason;

  Verification_list({
    this.verificationType,
    this.verificationReason,
  });

  static Verification_list fromJson(jsonRes) => jsonRes == null
      ? null
      : Verification_list(
          verificationType: jsonRes['verification_type'],
          verificationReason: jsonRes['verification_reason'],
        );

  Map<String, dynamic> toJson() => {
        'verification_type': verificationType,
        'verification_reason': verificationReason,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
