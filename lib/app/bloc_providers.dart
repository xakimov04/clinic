import 'package:clinic/core/di/injection_container.dart';
import 'package:clinic/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment_booking/appointment_booking_bloc.dart';
import 'package:clinic/features/client/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:clinic/features/client/home/presentation/bloc/clinics/clinics_bloc.dart';
import 'package:clinic/features/client/home/presentation/bloc/clinics_doctor/clinics_doctors_bloc.dart';
import 'package:clinic/features/client/home/presentation/bloc/doctor/doctor_bloc.dart';
import 'package:clinic/features/client/home/presentation/bloc/illness/illness_bloc.dart';
import 'package:clinic/features/client/news/presentation/bloc/news_bloc.dart';
import 'package:clinic/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final List<BlocProvider> appBlocProviders = [
  BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
  BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
  BlocProvider<DoctorBloc>(create: (_) => sl<DoctorBloc>()),
  BlocProvider<IllnessBloc>(create: (_) => sl<IllnessBloc>()),
  BlocProvider<ClinicsBloc>(create: (_) => sl<ClinicsBloc>()),
  BlocProvider<ChatListBloc>(create: (_) => sl<ChatListBloc>()),
  BlocProvider<ClinicsDoctorsBloc>(create: (_) => sl<ClinicsDoctorsBloc>()),
  BlocProvider<NewsBloc>(create: (_) => sl<NewsBloc>()..add(GetNewsEvent())),
  BlocProvider<AppointmentBookingBloc>(create: (_) => sl<AppointmentBookingBloc>()),
];
