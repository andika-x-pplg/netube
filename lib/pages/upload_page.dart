import 'package:flutter/material.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descController =
      TextEditingController();

  String selectedCategory = "Movie";

  final List<String> categories = [
    "Movie",
    "Shorts",
    "Music",
    "Gaming",
    "Education",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          "Upload Content",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // THUMBNAIL
            Container(
              height: 220,
              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius:
                    BorderRadius.circular(24),
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  CircleAvatar(
                    radius: 35,
                    backgroundColor:
                        Colors.redAccent,

                    child: const Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Upload Thumbnail",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // TITLE
            const Text(
              "Title",

              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _buildTextField(
              controller: titleController,
              hint: "Enter movie title",
            ),

            const SizedBox(height: 24),

            // DESCRIPTION
            const Text(
              "Description",

              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _buildTextField(
              controller: descController,
              hint: "Write description...",
              maxLines: 5,
            ),

            const SizedBox(height: 24),

            // CATEGORY
            const Text(
              "Category",

              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor:
                      const Color(0xFF111827),

                  value: selectedCategory,

                  isExpanded: true,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  items: categories.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedCategory =
                          value!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),

            // UPLOAD BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.redAccent,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                onPressed: () {},

                child: const Text(
                  "Upload Now",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          color: Colors.grey.shade500,
        ),

        filled: true,
        fillColor: const Color(0xFF111827),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}