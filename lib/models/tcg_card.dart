class TcgCard {
final String id;
final String name;
final String? smallImageUrl;
final String? largeImageUrl;


TcgCard({
required this.id,
required this.name,
required this.smallImageUrl,
required this.largeImageUrl,
});


factory TcgCard.fromJson(Map<String, dynamic> json) {
final images = json['images'] as Map<String, dynamic>?;
return TcgCard(
id: json['id'] as String,
name: json['name'] as String,
smallImageUrl: images != null ? images['small'] as String? : null,
largeImageUrl: images != null ? images['large'] as String? : null,
);
}
}