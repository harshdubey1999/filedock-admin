import 'package:file_dock/controllers/signIn_controller.dart';
import 'package:file_dock/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/colors.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final AuthController authcontroller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kbg1black500,
        appBar: CustomAppBar(onRefresh: controller.refreshData),
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/register_bg.jpg"),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  /// Profile Card
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 60),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kbg2lightblack300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),

                            /// Username
                            Obx(() => _info(
                                  "User Name",
                                  controller.userName,
                                )),

                            /// Email
                            Obx(() => _info(
                                  "Email",
                                  controller.email,
                                )),

                            /// Videos
                            Obx(() => _info(
                                  "No. of Videos",
                                  controller.videoCount.toString(),
                                )),

                            const SizedBox(height: 20),

                            /// Clicks & Earnings
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() => _highlight(
                                      "Clicks",
                                      controller.clicks.toString(),
                                    )),
                                Obx(() => _highlight(
                                      "Earned",
                                      "\$ ${controller.earnings.toStringAsFixed(2)}",
                                    )),
                              ],
                            ),

                            const SizedBox(height: 15),

                            /// Paid & Pending
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() => _highlight(
                                      "Paid",
                                      "\$ ${controller.paid.value.toStringAsFixed(2)}",
                                    )),
                                Obx(() => _highlight(
                                      "Pending",
                                      "\$ ${controller.pending.value.toStringAsFixed(2)}",
                                    )),
                              ],
                            ),

                            const SizedBox(height: 30),

                            /// Logout
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.red, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: authcontroller.signOut,
                                icon: const Icon(Icons.logout,
                                    color: Colors.red),
                                label: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Profile Image
                      Obx(() {
                        final photo = controller.photoUrl;
                        final name = controller.userName;

                        return Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade800,
                            child: photo.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      photo,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      ),
                                  )
                                : Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : "G",
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: ktext1white100, fontSize: 16),
          children: [
            TextSpan(text: "$title : "),
            TextSpan(
              text: value,
              style: TextStyle(
                color: kwhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlight(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(color: ktext2white200, fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: kwhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
