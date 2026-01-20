-- ============================================
-- PLACEMENT TRACKER - COMPLETE DATABASE SCHEMA
-- ============================================
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. CREATE USERS TABLE (extends auth.users)
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'student', 'trainer')),
  full_name TEXT,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CREATE STUDENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  college_name TEXT,
  qualification TEXT,
  passing_year INTEGER,
  batch TEXT, -- e.g., "2022-2026"
  primary_course TEXT,
  course_duration TEXT, -- e.g., "3_months", "6_months"
  skills TEXT[], -- Array of skills
  resume_url TEXT,
  eligibility_status TEXT CHECK (eligibility_status IN ('ready', 'training', 'not_eligible')),
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. CREATE COMPANIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  hr_name TEXT,
  hr_designation TEXT,
  hr_phone TEXT,
  hr_email TEXT,
  hr_linkedin TEXT,
  hiring_roles TEXT[], -- Array of roles
  last_contacted_date DATE,
  follow_up_reminder DATE,
  notes TEXT,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. CREATE PLACEMENT DRIVES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.placement_drives (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  job_role TEXT,
  location TEXT,
  salary_range TEXT,
  eligibility_criteria TEXT,
  drive_date DATE,
  application_deadline DATE,
  status TEXT CHECK (status IN ('upcoming', 'ongoing', 'completed', 'cancelled')),
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. CREATE PLACEMENT APPLICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.placement_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drive_id UUID REFERENCES public.placement_drives(id) ON DELETE CASCADE,
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
  status TEXT CHECK (status IN ('applied', 'shortlisted', 'interviewed', 'selected', 'rejected')),
  applied_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  interview_date TIMESTAMP WITH TIME ZONE,
  feedback TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(drive_id, student_id)
);

-- 6. CREATE APTITUDE TESTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.aptitude_tests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  test_type TEXT CHECK (test_type IN ('quantitative', 'reasoning', 'verbal', 'mixed')),
  total_marks INTEGER NOT NULL,
  duration_minutes INTEGER,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. CREATE APTITUDE RESULTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.aptitude_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  test_id UUID REFERENCES public.aptitude_tests(id) ON DELETE CASCADE,
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  max_score INTEGER NOT NULL,
  accuracy DECIMAL(5,2), -- Percentage
  time_taken_minutes INTEGER,
  test_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  feedback TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(test_id, student_id)
);

-- 8. CREATE MOCK INTERVIEWS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.mock_interviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
  interviewer_id UUID REFERENCES public.users(id),
  interview_type TEXT CHECK (interview_type IN ('hr', 'technical', 'managerial')),
  interview_date TIMESTAMP WITH TIME ZONE,
  communication_score INTEGER CHECK (communication_score BETWEEN 1 AND 10),
  technical_score INTEGER CHECK (technical_score BETWEEN 1 AND 10),
  confidence_score INTEGER CHECK (confidence_score BETWEEN 1 AND 10),
  overall_status TEXT CHECK (overall_status IN ('ready', 'needs_improvement', 'not_ready')),
  feedback TEXT,
  voice_note_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_students_email ON public.students(email);
CREATE INDEX IF NOT EXISTS idx_students_eligibility ON public.students(eligibility_status);
CREATE INDEX IF NOT EXISTS idx_companies_name ON public.companies(name);
CREATE INDEX IF NOT EXISTS idx_placement_drives_status ON public.placement_drives(status);
CREATE INDEX IF NOT EXISTS idx_placement_applications_student ON public.placement_applications(student_id);
CREATE INDEX IF NOT EXISTS idx_placement_applications_drive ON public.placement_applications(drive_id);
CREATE INDEX IF NOT EXISTS idx_aptitude_results_student ON public.aptitude_results(student_id);
CREATE INDEX IF NOT EXISTS idx_mock_interviews_student ON public.mock_interviews(student_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.placement_drives ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.placement_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aptitude_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aptitude_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mock_interviews ENABLE ROW LEVEL SECURITY;

-- ============================================
-- USERS TABLE POLICIES
-- ============================================
CREATE POLICY "Users can view their own data"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all users"
  ON public.users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- STUDENTS TABLE POLICIES
-- ============================================
CREATE POLICY "Anyone authenticated can view students"
  ON public.students FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can insert students"
  ON public.students FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update students"
  ON public.students FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete students"
  ON public.students FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- COMPANIES TABLE POLICIES
-- ============================================
CREATE POLICY "Admins can manage companies"
  ON public.companies FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Students can view companies"
  ON public.companies FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- ============================================
-- PLACEMENT DRIVES POLICIES
-- ============================================
CREATE POLICY "Anyone authenticated can view drives"
  ON public.placement_drives FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can manage drives"
  ON public.placement_drives FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- PLACEMENT APPLICATIONS POLICIES
-- ============================================
CREATE POLICY "Anyone authenticated can view applications"
  ON public.placement_applications FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can manage applications"
  ON public.placement_applications FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- APTITUDE TESTS POLICIES
-- ============================================
CREATE POLICY "Anyone authenticated can view tests"
  ON public.aptitude_tests FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins and trainers can manage tests"
  ON public.aptitude_tests FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('admin', 'trainer')
    )
  );

-- ============================================
-- APTITUDE RESULTS POLICIES
-- ============================================
CREATE POLICY "Anyone authenticated can view results"
  ON public.aptitude_results FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins and trainers can manage results"
  ON public.aptitude_results FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('admin', 'trainer')
    )
  );

-- ============================================
-- MOCK INTERVIEWS POLICIES
-- ============================================
CREATE POLICY "Anyone authenticated can view interviews"
  ON public.mock_interviews FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins and trainers can manage interviews"
  ON public.mock_interviews FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('admin', 'trainer')
    )
  );

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply update trigger to all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON public.students
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON public.companies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_placement_drives_updated_at BEFORE UPDATE ON public.placement_drives
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_placement_applications_updated_at BEFORE UPDATE ON public.placement_applications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_aptitude_tests_updated_at BEFORE UPDATE ON public.aptitude_tests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mock_interviews_updated_at BEFORE UPDATE ON public.mock_interviews
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SAMPLE DATA (OPTIONAL - FOR TESTING)
-- ============================================

-- Insert sample admin user (you'll need to create this user in Supabase Auth first)
-- Replace 'YOUR_ADMIN_USER_ID' with actual UUID from auth.users
/*
INSERT INTO public.users (id, email, role, full_name) VALUES
('YOUR_ADMIN_USER_ID', 'admin@example.com', 'admin', 'Admin User');
*/

-- Insert sample students
INSERT INTO public.students (name, email, phone, college_name, qualification, passing_year, batch, primary_course, eligibility_status, skills) VALUES
('John Doe', 'john@example.com', '9876543210', 'ABC College', 'B.Tech CSE', 2024, '2020-2024', 'Full Stack Development', 'ready', ARRAY['JavaScript', 'React', 'Node.js']),
('Jane Smith', 'jane@example.com', '9876543211', 'XYZ University', 'MCA', 2025, '2023-2025', 'Data Science', 'training', ARRAY['Python', 'Machine Learning', 'SQL']);

-- Insert sample companies
INSERT INTO public.companies (name, hr_name, hr_email, hr_phone, hiring_roles) VALUES
('Tech Corp', 'Sarah Johnson', 'sarah@techcorp.com', '9876543212', ARRAY['Software Engineer', 'Frontend Developer']),
('Data Solutions Inc', 'Mike Wilson', 'mike@datasolutions.com', '9876543213', ARRAY['Data Analyst', 'ML Engineer']);

-- ============================================
-- VIEWS FOR ANALYTICS (OPTIONAL)
-- ============================================

-- View for placement statistics
CREATE OR REPLACE VIEW placement_stats AS
SELECT 
  COUNT(DISTINCT s.id) as total_students,
  COUNT(DISTINCT CASE WHEN s.eligibility_status = 'ready' THEN s.id END) as ready_students,
  COUNT(DISTINCT c.id) as total_companies,
  COUNT(DISTINCT pd.id) as total_drives,
  COUNT(DISTINCT CASE WHEN pa.status = 'selected' THEN pa.student_id END) as placed_students
FROM students s
CROSS JOIN companies c
CROSS JOIN placement_drives pd
LEFT JOIN placement_applications pa ON pa.student_id = s.id;

-- View for student performance
CREATE OR REPLACE VIEW student_performance AS
SELECT 
  s.id,
  s.name,
  s.email,
  s.eligibility_status,
  AVG(ar.accuracy) as avg_aptitude_score,
  AVG((mi.communication_score + mi.technical_score + mi.confidence_score) / 3.0) as avg_interview_rating,
  COUNT(DISTINCT pa.id) as total_applications,
  COUNT(DISTINCT CASE WHEN pa.status = 'selected' THEN pa.id END) as successful_placements
FROM students s
LEFT JOIN aptitude_results ar ON ar.student_id = s.id
LEFT JOIN mock_interviews mi ON mi.student_id = s.id
LEFT JOIN placement_applications pa ON pa.student_id = s.id
GROUP BY s.id, s.name, s.email, s.eligibility_status;

-- ============================================
-- GRANT PERMISSIONS
-- ============================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- ============================================
-- COMPLETION MESSAGE
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '✅ Placement Tracker Database Schema Created Successfully!';
  RAISE NOTICE '📊 Tables: users, students, companies, placement_drives, placement_applications, aptitude_tests, aptitude_results, mock_interviews';
  RAISE NOTICE '🔒 RLS Policies: Enabled with role-based access control';
  RAISE NOTICE '📈 Views: placement_stats, student_performance';
  RAISE NOTICE '⚡ Next Steps:';
  RAISE NOTICE '   1. Create test users in Supabase Auth';
  RAISE NOTICE '   2. Add their IDs to the users table with appropriate roles';
  RAISE NOTICE '   3. Test the app with different role logins';
END $$;
