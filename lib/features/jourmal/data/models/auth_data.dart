class GoogleAuthData {
  final String? name;
  final String? email;
  final bool success;
  final String? error;
  final String? image;
  final String? token;
  final String? id;
  final String? brearerToken;

  GoogleAuthData({
    this.name,
    this.email,
    this.success = false,
    this.error,
    this.image,
    this.token,
    this.id,
    this.brearerToken,
  });

  factory GoogleAuthData.fromJson(Map<String, dynamic> json) => GoogleAuthData(
        name: json["name"],
        email: json["email"],
        success: json["success"],
        error: json["error"],
        image: json["image"],
        token: json["token"],
        id: json["id"],
        brearerToken: json["brearerToken"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "success": success,
        "error": error,
        "image": image,
        "token": token,
        "id": id,
        "brearerToken": brearerToken,
      };
}
