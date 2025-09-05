// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // assuming sl is here
// import '../bloc/profile_bloc.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => sl<ProfileBloc>()..add(LoadProfileEvent()),
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pushReplacementNamed(context, "/chatPage");
//             },
//           ),
//           title: Image.asset("assets/logo/app_logo.png", height: 40),
//           centerTitle: true,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.subscriptions),
//               onPressed: () {
//                 Navigator.pushNamed(context, "/subscriptionPage");
//               },
//             ),
//             // The new Logout button
//             BlocBuilder<ProfileBloc, ProfileState>(
//               builder: (context, state) {
//                 // We only show the button if the profile is loaded.
//                 if (state is ProfileLoaded) {
//                   return IconButton(
//                     icon: const Icon(Icons.logout),
//                     onPressed: () {
//                       BlocProvider.of<ProfileBloc>(context).add(LogoutEvent());
//                     },
//                   );
//                 }
//                 return const SizedBox();
//               },
//             ),
//           ],
//         ),
//         // Use BlocListener to handle navigation on state changes
//         body: BlocListener<ProfileBloc, ProfileState>(
//           listener: (context, state) {
//             // If the state is ProfileLoggedOut, navigate to the sign-in page
//             if (state is ProfileLoggedOut) {
//               Navigator.pushReplacementNamed(context, "/signInPage");
//             }
//           },
//           child: BlocBuilder<ProfileBloc, ProfileState>(
//             builder: (context, state) {
//               if (state is ProfileLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (state is ProfileLoaded) {
//                 final profile = state.profile;
//                 return ProfileBloc(profile: profile);
//               } else if (state is ProfileError) {
//                 return Center(child: Text(state.message));
//               }
//               return const SizedBox();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }