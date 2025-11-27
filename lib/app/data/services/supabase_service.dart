// lib/app/data/services/supabase_service.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  // Getter untuk mengakses client Supabase
  SupabaseClient get client => Supabase.instance.client;

  Future<SupabaseService> init() async {
    await Supabase.initialize(
      // Ganti dengan URL dan Key Supabase Anda
      url: 'https://bdzcizlwrznfixiimklq.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkemNpemx3cnpuZml4aWlta2xxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMTU3MzYsImV4cCI6MjA3ODc5MTczNn0.8t53q1sl2psM8Xhhs0y0oBwxxXfRvWGp3FGz8Da0tXM',
    );
    return this;
  }
}
