import 'package:flutter/material.dart';

class KrishnaProfileScreen extends StatelessWidget {
  const KrishnaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Krishna Byre Gowda'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Full image section
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/krishna-byre-gowda-1528518631.jpg',
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  const Text(
                    'Krishna Byre Gowda',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  const Text(
                    'Minister of Revenue, Government of Karnataka & MLA of Byatarayanapura',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Krishna Byre Gowda is a prominent Indian politician from Karnataka who has made significant contributions to the state\'s political landscape. Born into a family with strong political roots, he has dedicated his career to public service and governance.\n\n'
                    'As the current Minister of Revenue in the Government of Karnataka, Krishna Byre Gowda oversees one of the most crucial portfolios in the state administration. His role involves managing revenue collection, land records, and various fiscal policies that directly impact the lives of millions of Karnataka residents.\n\n'
                    'His journey in politics began with his election as a Member of the Legislative Assembly (MLA) representing the Byatarayanapura constituency. This constituency, located in Bangalore, has been his political stronghold where he has consistently worked for the welfare and development of his constituents.\n\n'
                    'Throughout his tenure, Krishna Byre Gowda has been known for his approachable nature and commitment to addressing the concerns of common people. He has been instrumental in implementing various development schemes and initiatives in his constituency and across the state.\n\n'
                    'His administrative experience and deep understanding of governance have made him a valuable member of the state cabinet. As Revenue Minister, he has been involved in important policy decisions that affect property registration, stamp duties, and other revenue-related matters.\n\n'
                    'Krishna Byre Gowda continues to serve the people of Karnataka with dedication, working towards the betterment of the state through effective governance and development initiatives. His leadership in the Revenue department plays a vital role in the state\'s economic framework and administrative efficiency.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
