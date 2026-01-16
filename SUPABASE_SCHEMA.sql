-- 1. ENABLE USERS TABLE (Already done in Day 2, but ensuring here)
-- This table stores user roles (admin, student, trainer) using the Supabase Auth ID.
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  role text check (role in ('admin','student','trainer')) not null,
  created_at timestamp with time zone default now()
);

-- Enable RLS for users
alter table public.users enable row level security;

-- Policies for users
create policy "Users can read own data" on public.users for select using (auth.uid() = id);
-- Allow users to insert their own data (needed during signup if applicable, or manual insert)
create policy "Users can insert own data" on public.users for insert with check (auth.uid() = id);


-- 2. CREATE STUDENTS TABLE
-- Stores all student details, education, course info, and placement status.
create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  
  -- Basic Info
  name text not null,
  phone text,
  email text,
  
  -- Education
  qualification text,
  specialization text,
  passing_year int,
  
  -- Course Details (Institute Specific)
  primary_course text, 
  course_duration text check (course_duration in ('1_month','3_months','6_months','9_months')),
  course_start_date date,
  course_end_date date,
  course_status text check (course_status in ('ongoing','completed','discontinued')) default 'ongoing',
  
  -- Skills & Experience
  skills text[],
  experience_level text check (experience_level in ('fresher','career_switcher','experienced')),
  
  -- Placement Readiness
  eligibility_status text check (eligibility_status in ('ready','training','not_eligible')) default 'training',
  placement_level text check (placement_level in ('beginner','intermediate','job_ready')) default 'beginner',
  internship_status text check (internship_status in ('not_started','ongoing','completed')) default 'not_started',
  
  resume_url text, -- Link to Google Drive / One Drive PDF
  
  created_at timestamp with time zone default now()
);

-- Enable RLS for students
alter table public.students enable row level security;

-- Policies for students
-- Admins have full access
create policy "Admin full access on students" on public.students for all using (
  exists (select 1 from public.users where users.id = auth.uid() and users.role = 'admin')
);
-- Students can view ONLY their own profile (assuming we link student auth id to this table later, 
-- but for now, let's keep it admin-managed. If students login, we might need a 'user_id' column in this table)
-- Adding user_id column for future Phase 2 (Student Login linking):
alter table public.students add column if not exists user_id uuid references auth.users(id);


-- 3. CREATE COMPANIES TABLE
-- Stores HR and Company details for placement drives.
create table if not exists public.companies (
  id uuid primary key default gen_random_uuid(),
  company_name text not null,
  hr_name text,
  phone text,
  email text,
  linkedin text,
  last_contacted date,
  follow_up_date date,
  created_at timestamp with time zone default now()
);

-- Enable RLS for companies
alter table public.companies enable row level security;

-- Policies for companies
create policy "Admin full access on companies" on public.companies for all using (
  exists (select 1 from public.users where users.id = auth.uid() and users.role = 'admin')
);


-- 4. CREATE APTITUDE TESTS TABLE
-- Stores test metadata created by admins.
create table if not exists public.aptitude_tests (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  type text check (type in ('quant','reasoning','verbal','coding')),
  assigned_batch text, -- Could be a batch ID or name
  total_marks int default 100,
  created_by uuid references public.users(id),
  created_at timestamp with time zone default now()
);

-- Enable RLS for aptitude_tests
alter table public.aptitude_tests enable row level security;

create policy "Admin full access on aptitude_tests" on public.aptitude_tests for all using (
  exists (select 1 from public.users where users.id = auth.uid() and users.role = 'admin')
);
-- Students can read tests assigned to them (Phase 2 logic)


-- 5. CREATE APTITUDE RESULTS TABLE
-- Stores scores of students.
create table if not exists public.aptitude_results (
  id uuid primary key default gen_random_uuid(),
  student_id uuid references public.students(id) on delete cascade,
  test_id uuid references public.aptitude_tests(id) on delete cascade,
  score int,
  max_score int,
  accuracy float,
  time_taken_minutes int,
  created_at timestamp with time zone default now()
);

-- Enable RLS for aptitude_results
alter table public.aptitude_results enable row level security;

create policy "Admin full access on aptitude_results" on public.aptitude_results for all using (
  exists (select 1 from public.users where users.id = auth.uid() and users.role = 'admin')
);


-- 6. CREATE MOCK INTERVIEWS TABLE
-- Stores records of mock interviews conducted by trainers/admins.
create table if not exists public.mock_interviews (
  id uuid primary key default gen_random_uuid(),
  student_id uuid references public.students(id) on delete cascade,
  interviewer_id uuid references public.users(id),
  interview_type text check (interview_type in ('hr','technical','managerial')),
  
  -- Scoring (1-10 scale)
  communication_score int,
  technical_score int,
  confidence_score int,
  body_language_score int,
  
  feedback text,
  status text check (status in ('ready','needs_improvement','not_ready')),
  
  conducted_at timestamp with time zone default now()
);

-- Enable RLS for mock_interviews
alter table public.mock_interviews enable row level security;

create policy "Admin full access on mock_interviews" on public.mock_interviews for all using (
  exists (select 1 from public.users where users.id = auth.uid() and users.role = 'admin')
);


-- 7. CREATE PLACEMENT DRIVES TABLE
-- Stores actual job openings/drives.
create table if not exists public.placement_drives (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies(id) on delete cascade,
  job_role text not null,
  description text,
  drive_date date,
  salary_package text, -- e.g. "4-6 LPA"
  status text check (status in ('scheduled','completed','cancelled')) default 'scheduled',
  created_at timestamp with time zone default now()
);

-- Enable RLS for placement_drives
alter table public.placement_drives enable row level security;

create policy "Admin full access on placement_drives" on public.placement_drives for all using (
  exists (select 1 from public.users where users.id = auth.uid() and users.role = 'admin')
);


-- 8. CREATE DRIVE APPLICATIONS TABLE
-- Stores which student applied/shortlisted for which drive.
create table if not exists public.drive_applications (
  id uuid primary key default gen_random_uuid(),
  drive_id uuid references public.placement_drives(id) on delete cascade,
  student_id uuid references public.students(id) on delete cascade,
  
  status text check (status in ('applied','shortlisted','interviewed','selected','rejected')) default 'applied',
  notes text, -- e.g. "Rejected in Round 2"
  
  updated_at timestamp with time zone default now()
);

-- Enable RLS for drive_applications
alter table public.drive_applications enable row level security;

create policy "Admin full access on drive_applications" on public.drive_applications for all using (
  exists (select 1 from public.users where users.id = auth.uid() and users.role = 'admin')
);
