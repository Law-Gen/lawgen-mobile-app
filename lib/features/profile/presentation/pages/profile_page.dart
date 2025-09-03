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
//           ],
//         ),
//         body: BlocBuilder<ProfileBloc, ProfileState>(
//           builder: (context, state) {
//             if (state is ProfileLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is ProfileLoaded) {
//               final profile = state.profile;
//               return ProfileForm(profile: profile);
//             } else if (state is ProfileError) {
//               return Center(child: Text(state.message));
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }
// }
