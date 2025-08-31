import 'package:shared_preferences/shared_preferences.dart';

enum Gender { none, male, female, other }

class Profile {
  String name;
  String username;
  String bio;
  List<String> links;
  List<String> interests;
  Gender gender;
  String contactEmail;
  String phone;
  String instagram;
  String pinterest;

  Profile({
    this.name = '',
    this.username = '',
    this.bio = '',
    List<String>? links,
    List<String>? interests,
    this.gender = Gender.none,
    this.contactEmail = '',
    this.phone = '',
    this.instagram = '',
    this.pinterest = '',
  })  : links = links ?? [],
        interests = interests ?? [];

  static Profile fromPrefs(SharedPreferences prefs) {
    final genderName = prefs.getString('profile.gender') ?? 'none';
    final gender = Gender.values.firstWhere(
      (e) => e.name == genderName,
      orElse: () => Gender.none,
    );
    return Profile(
      name: prefs.getString('profile.name') ?? '',
      username: prefs.getString('profile.username') ?? '',
      bio: prefs.getString('profile.bio') ?? '',
      links: prefs.getStringList('profile.links') ?? [],
      interests: prefs.getStringList('profile.interests') ?? [],
      gender: gender,
      contactEmail: prefs.getString('profile.contactEmail') ?? '',
      phone: prefs.getString('profile.phone') ?? '',
      instagram: prefs.getString('profile.instagram') ?? '',
      pinterest: prefs.getString('profile.pinterest') ?? '',
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile.name', name);
    await prefs.setString('profile.username', username);
    await prefs.setString('profile.bio', bio);
    await prefs.setStringList('profile.links', links);
    await prefs.setStringList('profile.interests', interests);
    await prefs.setString('profile.gender', gender.name);
    await prefs.setString('profile.contactEmail', contactEmail);
    await prefs.setString('profile.phone', phone);
    await prefs.setString('profile.instagram', instagram);
    await prefs.setString('profile.pinterest', pinterest);
  }
}

class ProfileService {
  static Future<Profile> load() async {
    final prefs = await SharedPreferences.getInstance();
    return Profile.fromPrefs(prefs);
  }
}
