-- ============================================================
-- NPS Dashboard — domain-based access control (Supabase)
-- Run this whole file in Supabase → SQL Editor → New query → Run
-- ============================================================

-- 1) WHO CAN SEE WHAT ------------------------------------------------
create table if not exists public.user_access (
  email           text primary key,
  full_name       text,
  employee_code   text,
  department      text,
  is_admin        boolean not null default false,   -- "All domains" people
  allowed_domains text[]  not null default '{}'      -- specific domains for everyone else
);
alter table public.user_access enable row level security;

-- a signed-in user may read only their OWN access row
drop policy if exists "read own access" on public.user_access;
create policy "read own access" on public.user_access
  for select using ( (auth.jwt() ->> 'email') = email );

-- 2) THE NPS DATA (moved server-side so it can be filtered per user) --
create table if not exists public.nps_feedback (
  id            bigint generated always as identity primary key,
  pax_user_id   text,
  outlet        text,
  avg_rating    numeric,
  nps_category  text,
  domain        text,
  terminal      text,
  movement      text,
  channel       text,
  submitted_on  date,
  feedback      text
);
alter table public.nps_feedback enable row level security;

-- 3) THE ACTUAL RULE: a user sees a feedback row only if they are an
--    admin, OR the row's domain is in their allowed_domains list.
drop policy if exists "domain scoped read" on public.nps_feedback;
create policy "domain scoped read" on public.nps_feedback
  for select using (
    exists (
      select 1 from public.user_access ua
      where ua.email = (auth.jwt() ->> 'email')
        and ( ua.is_admin = true
              or public.nps_feedback.domain = any(ua.allowed_domains) )
    )
  );

-- 4) SEED THE ACCESS LIST (generated from Employee_List.xlsx) ---------
insert into public.user_access (email,full_name,employee_code,department,is_admin,allowed_domains) values
  ('ajay.rao@bialairport.com','Ajay Rao','103713','Digital',true,'{}'),
  ('ajinkya.m@bialairport.com','Ajinkya Mukund Jangale','103466','Operations',false,'{"Cab"}'),
  ('akash.a@bialairport.com','Akash Awasthi','102268','Digital',true,'{}'),
  ('alphin.j@bialairport.com','Alphin Infant J','102013','Operations',false,'{"Cab"}'),
  ('amit.paul@bialairport.com','Amit Vijay Paul','103431','Operations',false,'{"Retail"}'),
  ('anand.v@bialairport.com','Anand Viswanath','103352','Digital',true,'{}'),
  ('anindita@bialairport.com','Anindita Sengupta','101579','CCO',true,'{}'),
  ('ashish.b@bialairport.com','Ashish Bakshi','102325','BASL',false,'{"080Cafe","TransitHotel","SpaSalon","Lounge"}'),
  ('avinash.b@bialairport.com','Avinash B','102377','Operations',false,'{"Cab"}'),
  ('avishek@bialairport.com','Avishek Das','103587','DutyFree',false,'{"Duty Free"}'),
  ('bhupender.r@bialairport.com','Bhupender Singh Rana','103522','Operations',false,'{"Retail"}'),
  ('dipti@bialairport.com','Dipti Gupta','101681','Operations',false,'{"FnB"}'),
  ('dominic@bialairport.com','Dominic Devasia','101814','Operations',true,'{}'),
  ('durairaj@bialairport.com','Durairaj M','102745','Operations',false,'{"Cab"}'),
  ('george.k@bialairport.com','George Bennet Kuruvilla','103341','BASL',false,'{"080Cafe","TransitHotel","SpaSalon","Lounge"}'),
  ('jitender.k@bialairport.com','Jitender Kallappa Dhule','103382','Operations',false,'{"Cab"}'),
  ('kaustuv@bialairport.com','Kaustuv Roy','102734','Operations',false,'{"Retail"}'),
  ('kenneth@bialairport.com','Kenneth Rosvang Guldbjerg','101657','CCO',true,'{}'),
  ('kiran.bk@bialairport.com','Kiran Kumar B','103479','Operations',false,'{"Cab"}'),
  ('kiran.kb@bialairport.com','Kiran Kumar B M','103343','Digital',true,'{}'),
  ('lingaraju.b@bialairport.com','Lingaraju BS','103500','Operations',false,'{"Cab"}'),
  ('manjappagowda.c@bialairport.com','Manjappa Gowda C S','103554','Operations',true,'{}'),
  ('manoj.hs@bialairport.com','Manoj Hodigere Somashekhrappa','103607','Operations',false,'{"Cab"}'),
  ('midhun@bialairport.com','Midhun Raveendranath','102684','DutyFree',false,'{"Duty Free"}'),
  ('javeed@bialairport.com','Mohammed Javeed','101604','Operations',false,'{"Retail"}'),
  ('munegowda@bialairport.com','Munegowda K V','102810','Operations',false,'{"Cab"}'),
  ('musthaq@bialairport.com','Musthaq Ahamed','102466','Digital',true,'{}'),
  ('naveenkumar.cj@bialairport.com','Naveen Kumar C J','102666','Operations',false,'{"Cab"}'),
  ('neeraj.m@bialairport.com','Neeraj Manoria','102149','Digital',true,'{}'),
  ('neeraj.p@bialairport.com','Neeraj Prakash','102754','CCO',true,'{}'),
  ('noel@bialairport.com','Noel Patrick Lewis','101474','CCB',false,'{"CBB"}'),
  ('prabhu@bialairport.com','Prabhu U','102923','Operations',true,'{}'),
  ('pradip.p@bialairport.com','Pradip Poria','103369','CCB',false,'{"CBB"}'),
  ('raghavendra.p@bialairport.com','Raghavendra Patil','103443','Operations',false,'{"Cab"}'),
  ('rohan.c@bialairport.com','Rohan Choudhury','103743','Operations',false,'{"FnB"}'),
  ('sambasiva@bialairport.com','Sambasiva C','101241','Operations',false,'{"Cab"}'),
  ('sanjaychandra@bialairport.com','Sanjay Chandra B','100893','Operations',false,'{"Cab"}'),
  ('sanjay.prasad@bialairport.com','Sanjay Prasad','102744','Operations',false,'{"FnB"}'),
  ('shankarendra.m@bialairport.com','Shankarendra M','103433','Operations',false,'{"Cab"}'),
  ('sharath.s@bialairport.com','Sharath Srirama','103698','Digital',true,'{}'),
  ('shiva@bialairport.com','Shiva Kumar K','102598','Operations',false,'{"Cab"}'),
  ('shreedhar@bialairport.com','Shreedhar Babu R','102192','BASL',false,'{"080Cafe","TransitHotel","SpaSalon","Lounge"}'),
  ('somashekharappa@bialairport.com','SOMASHEKHARAPPA C. J.','103521','Operations',false,'{"Cab"}'),
  ('srikanth@bialairport.com','Srikanth B','103247','BASL',false,'{"080Cafe","TransitHotel","SpaSalon","Lounge"}'),
  ('srikanth.v@bialairport.com','Srikanth V','101653','Operations',false,'{"Cab"}'),
  ('stephen@bialairport.com','Stephen Alphonse Raj J','101314','Operations',false,'{"Cab"}'),
  ('sunil.benni@bialairport.com','Sunil Benni','103387','Operations',false,'{"Cab"}'),
  ('suresh.mv@bialairport.com','Suresh Babu M V','103715','Operations',false,'{"Cab"}'),
  ('syedazhar@bialairport.com','Syed Azhar Hassan','100849','Operations',false,'{"Cab"}'),
  ('syed.sameeruddin@bialairport.com','Syed Sameeruddin','102661','Operations',false,'{"Cab"}'),
  ('praveen.t@bialairport.com','T S Praveen','103742','Operations',false,'{"Cab"}'),
  ('vaibhav.mohan@bialairport.com','Vaibhav Mohan','103798','Operations',true,'{}'),
  ('vaishakh@bialairport.com','Vaishakh T','103811','DutyFree',false,'{"Duty Free"}'),
  ('vanishri@bialairport.com','Vanishri A','100484','Digital',true,'{}'),
  ('vasudevamurthy@bialairport.com','Vasudevamurthy H B','102735','Operations',false,'{"Cab"}'),
  ('veeresh.ma@bialairport.com','Veeresh M A','800027','Operations',true,'{}'),
  ('vinoth.kumar@bialairport.com','Vinoth Kumar R','102785','Operations',false,'{"FnB"}'),
  ('vipin.c@bialairport.com','Vipin Chengappa Konerira','103386','Operations',false,'{"Cab"}'),
  ('yogesha.gg@bialairport.com','Yogesha G G','102370','Operations',false,'{"Cab"}')
on conflict (email) do update set is_admin=excluded.is_admin, allowed_domains=excluded.allowed_domains, full_name=excluded.full_name, department=excluded.department;
