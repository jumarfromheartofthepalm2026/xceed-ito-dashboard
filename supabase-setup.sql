-- ══════════════════════════════════════════
-- Xceed ITO Dashboard — Supabase Setup SQL
-- Run this in: https://supabase.com/dashboard/project/wmmqymlbamrwbdthfbdd/sql/new
-- ══════════════════════════════════════════

-- Step 1: Extensions
create extension if not exists "uuid-ossp";

-- ── User Profiles (admin or viewer) ──────
create table if not exists ito_user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null default 'viewer' check (role in ('admin', 'viewer')),
  created_at timestamptz default now()
);

alter table ito_user_profiles enable row level security;

create policy "users_read_own_profile" on ito_user_profiles
  for select using (auth.uid() = id);

-- ── Vendors Table ─────────────────────────
create table if not exists ito_vendors (
  id uuid primary key default uuid_generate_v4(),
  category text not null,
  company text not null,
  countries text[] default '{}',
  scope text,
  status text,
  status_key text,
  details text,
  commitment text,
  requirements text,
  target_audience text,
  leads_generation text,
  sort_order integer default 0,
  updated_at timestamptz default now(),
  updated_by text
);

alter table ito_vendors enable row level security;

-- Everyone logged in can read vendors
create policy "authenticated_read_vendors" on ito_vendors
  for select using (auth.role() = 'authenticated');

-- Only admins can insert/update/delete
create policy "admins_write_vendors" on ito_vendors
  for all using (
    exists (select 1 from ito_user_profiles where id = auth.uid() and role = 'admin')
  );

-- ── Audit Log ─────────────────────────────
create table if not exists ito_audit_log (
  id uuid primary key default uuid_generate_v4(),
  vendor_id uuid references ito_vendors(id),
  vendor_name text,
  field_changed text,
  old_value text,
  new_value text,
  changed_by text,
  changed_at timestamptz default now()
);

alter table ito_audit_log enable row level security;

create policy "authenticated_read_audit" on ito_audit_log
  for select using (auth.role() = 'authenticated');

create policy "admins_write_audit" on ito_audit_log
  for insert with check (
    exists (select 1 from ito_user_profiles where id = auth.uid() and role = 'admin')
  );

-- ══════════════════════════════════════════
-- Step 2: Seed all 25 vendors
-- ══════════════════════════════════════════

insert into ito_vendors (category, company, countries, scope, status, status_key, details, commitment, requirements, target_audience, leads_generation, sort_order) values

-- Data Management
('Data Management', 'Acronis', ARRAY['UAE','KSA','Morocco','Mauritius'],
 'Cyber Backup, Endpoint Protection, Disaster Recovery as a Service',
 'Registered — Testing', 'registered-testing',
 'Registered and testing partner cyber console (Nov 2026)',
 'Take a Decision by Dec 2026',
 'Complete evaluation of Cyber Console; confirm MSP pricing tier',
 'SMB, Mid-Market — all markets',
 'MSP model: per-seat monthly billing; SMEs in UAE Freezones, KSA private sector, Morocco nearshore companies',
 1),

('Data Management', 'NetApp', ARRAY['UAE','KSA'],
 'Enterprise Storage (ONTAP), Cloud Volumes ONTAP, Azure NetApp Files, DR Replication',
 'Waiting for Vendor Feedback', 'waiting-vendor-feedback',
 'Registered with NetApp (Nov 2026); awaiting feedback mail',
 'Waiting for vendor response',
 'Complete legal review; resolve partner training certification requirement',
 'Enterprise — Banks, Aramco, SABIC, large corporates in KSA & UAE',
 'Target: KSA government & banking sector; UAE enterprise hybrid storage deals',
 2),

('Data Management', 'Cohesity', ARRAY['UAE','KSA','Mauritius'],
 'Data Management Platform, DataProtect SaaS, Fort Knox DR, DataHawk Security',
 'Waiting for Vendor Feedback', 'waiting-vendor-feedback',
 'Registered with Cohesity (Nov 2026); awaiting feedback mail',
 'Waiting for vendor response',
 'Complete partner onboarding after vendor feedback',
 'Enterprise — UAE & KSA large organizations',
 'Replace legacy backup (Veritas) in Enterprise; DR as a Service to Mauritius',
 3),

('Data Management', 'Veeam', ARRAY['UAE','KSA','Morocco','Mauritius'],
 'Backup & Replication, Cloud Tier (AWS/Azure), DR as a Service',
 'On Hold', 'on-hold',
 'On hold until accurate opportunity identified (Oct 2026)',
 'Reconsider — register for ProPartner now',
 '2 certified engineers + $50K annual revenue for Silver tier (ProPartner Program)',
 'Mid-Market & Enterprise — all Gulf markets',
 'Managed Backup Service (monthly fee); DR as a Service — KSA/UAE on-prem to cloud DR',
 4),

('Data Management', 'Arctera', ARRAY[]::text[],
 'Desktop Backup (Veritas spin-off)',
 'Dropped', 'dropped',
 'Not a match — desktop backup solution only; dropped Oct 2026',
 'No action',
 'N/A — does not fit Xceed ITO profile',
 'N/A',
 'No leads — dropped',
 5),

-- Infrastructure Security
('Infrastructure Security', 'Fortinet', ARRAY['UAE','KSA','Morocco','Mauritius','Egypt'],
 'Next-Gen Firewall (FortiGate), FortiEDR, FortiSASE, SD-WAN, FortiCare Support',
 'Not Applied — Urgent', 'not-applied-urgent',
 'Not yet applied to FortiPartner program; most critical gap',
 'Register for FortiPartner immediately — fastest deal generator',
 'FortiPartner Registered tier: minimal requirements; 3 engineers for Silver',
 'SMB, Mid-Market, Enterprise — all 5 markets; widest addressable base',
 'FortiGate hardware resell + annual FortiCare support contracts; SMB to Enterprise',
 6),

('Infrastructure Security', 'Microsoft', ARRAY['UAE','KSA','Morocco','Mauritius','Egypt'],
 'Microsoft 365 CSP, Azure Cloud, Security (Defender), Teams, SharePoint',
 'Waiting for Vendor — Ingram Micro Issue', 'waiting-vendor-issue',
 'Legal & finance replied; Ingram Micro portal registration blocked (Oct 2026)',
 'Call Mohamed Malek & Engineer Waleed to unblock registration',
 'Resolve Ingram Micro portal issue; CSP tier sufficient to start',
 'All segments — SMB to Enterprise in all markets',
 'CSP monthly commission on M365 licenses — highest volume recurring revenue',
 7),

('Infrastructure Security', 'Barracuda', ARRAY['UAE','KSA','Morocco'],
 'Email Security, Cloud Backup, Web Application Firewall, Zero Trust',
 'Waiting for Vendor Feedback', 'waiting-vendor-feedback',
 'Contacted vendor (Nov 2026); meeting to discuss partner requirements/level',
 'Complete meeting; confirm partner tier and requirements',
 'Partner program requirements TBD after meeting',
 'SMB — UAE Freezones, KSA private sector, Morocco SMB',
 'Email security SaaS subscription + managed email filtering service',
 8),

('Infrastructure Security', 'Nutanix', ARRAY['UAE','KSA'],
 'HCI (Hyperconverged Infrastructure), NC2 on AWS/Azure, VMware Migration',
 'Waiting for Xceed — Pending Internal Docs', 'waiting-xceed',
 'Partnership onboarding pending Finance, Sales & Technical team documentation (Oct 2026)',
 'Complete internal paperwork urgently — VMware migration window is now',
 'Coordinate Finance, Sales & Tech teams to complete onboarding documentation',
 'Mid-Market & Enterprise — companies migrating from VMware (Broadcom price hike)',
 'VMware → Nutanix migration projects (large one-time fees) + NC2 cloud licensing',
 9),

('Infrastructure Security', 'BlueCat', ARRAY['UAE','KSA'],
 'DNS, DHCP, IP Address Management (DDI/IPAM)',
 'Waiting for Xceed — Signature Required', 'waiting-xceed',
 'Partnership agreement sent; awaiting Xceed signature on previously shared agreement (Oct 2026)',
 'Sign the agreement THIS WEEK — contract is ready',
 'Sign and return partnership agreement — no additional requirements',
 'Enterprise — large networks with complex IP management needs',
 'Annual license resell + DNS management professional services',
 10),

('Infrastructure Security', 'Tenable', ARRAY['UAE','KSA'],
 'Vulnerability Management (Tenable.io SaaS, Nessus Pro, Tenable.sc)',
 'Waiting for Xceed — Pending Internal Docs', 'waiting-xceed',
 'Onboarding pending Finance, Sales & Technical team info (Oct 2026)',
 'Coordinate internally to complete onboarding',
 'Complete Finance, Sales & Tech documentation for partner onboarding',
 'Enterprise — NCA compliance mandates in KSA; UAE financial sector',
 'License resell + quarterly vulnerability scan reports for NCA/CBUAE compliance',
 11),

('Infrastructure Security', 'Red Hat', ARRAY['KSA','UAE','Morocco'],
 'RHEL (Red Hat Enterprise Linux), OpenShift, Ansible Automation',
 'Waiting for Vendor Feedback', 'waiting-vendor-feedback',
 'Application submitted (Nov 2026); waiting for vendor response',
 'Await vendor approval',
 'Red Hat Partner Ready program requirements pending',
 'Enterprise — KSA Vision 2030 government projects, UAE large enterprise',
 'RHEL subscription resell + OpenShift implementation projects',
 12),

('Infrastructure Security', 'AWS', ARRAY['UAE','KSA','Morocco','Egypt'],
 'Cloud Infrastructure, Storage, DR (AWS Regions: UAE, KSA, Cairo)',
 'Waiting for Vendor — Application Issue', 'waiting-vendor-issue',
 'Application submitted with issue; case opened with partner support (Nov 2026)',
 'Waiting for feedback from AWS partner support on rejection',
 'Resolve application issue with AWS partner support; APN Select tier target',
 'All segments in all markets — cloud infrastructure base',
 'AWS resell + managed cloud services; DR as a Service (Mauritius via AWS Johannesburg)',
 13),

('Infrastructure Security', 'Kaspersky', ARRAY['Morocco','Mauritius','Egypt'],
 'Endpoint Security, Threat Intelligence, Anti-APT',
 'Waiting for Vendor — Distributor Issue', 'waiting-vendor-issue',
 'Application sent; Amaviz not listed as distributor in Egypt (Nov 2026)',
 'Resolve distributor issue via Kaspersky partnership support',
 'Find alternative distributor or direct partnership route in Egypt',
 'SMB — Morocco, Mauritius, Egypt only (banned/restricted in UAE/KSA government)',
 'Endpoint license resell for SMB; NOT suitable for Gulf government sector',
 14),

('Infrastructure Security', 'Google', ARRAY['UAE','KSA','Morocco'],
 'Google Workspace, Google Cloud Platform (GCP)',
 'Waiting for Vendor — Slow Progress', 'waiting-vendor-issue',
 'Progress delayed; difficulty identifying correct partnership contact (Nov 2026)',
 'Escalate follow-up; establish direct contact with partnership team',
 'Identify and reach correct Google partnership contact',
 'SMB to Mid-Market — Workspace for Morocco French companies; GCP for developers',
 'Google Workspace CSP resell + GCP project billing margin',
 15),

('Infrastructure Security', 'Darktrace', ARRAY['UAE','KSA'],
 'AI Cybersecurity, Network Detection & Response, Email Security AI',
 'Not Contacted', 'not-contacted',
 'Not contacted yet',
 'Assign responsible person',
 'Darktrace MSSP/Partner program — requires cybersecurity capability proof',
 'Enterprise only — large security budget organizations in UAE & KSA',
 'Annual platform license + AI security managed service overlay',
 16),

('Infrastructure Security', 'SOCRadar', ARRAY['UAE','KSA'],
 'Threat Intelligence Platform, Digital Risk Protection, Dark Web Monitoring',
 'Waiting for Vendor Feedback', 'waiting-vendor-feedback',
 'Application submitted (Nov 2026); waiting for vendor response',
 'Await vendor feedback',
 'SOCRadar partner program requirements pending',
 'Enterprise — SOC teams in UAE & KSA banks and telcos',
 'Annual threat intel subscription resell + managed CTI service',
 17),

('Infrastructure Security', 'Thinscale', ARRAY['Morocco','UAE'],
 'Virtual Desktop, Secure Remote Worker, BPO endpoint management',
 'Waiting for Xceed — Needs Clarification', 'waiting-xceed',
 'Initial contact established; vendor interested but needs clarifications (Oct 2026)',
 'Respond with required clarifications to vendor',
 'Provide clarifications on Xceed BPO use case and volume',
 'BPO/Nearshore companies — Morocco French companies, UAE Freezone BPO',
 'Per-seat monthly subscription; unique fit for Xceed''s BPO client base',
 18),

('Infrastructure Security', 'Sahara.com', ARRAY['UAE','KSA'],
 'Professional Services marketplace / SI platform',
 'Waiting for Xceed — Internal Meeting Needed', 'waiting-xceed',
 'Meeting needed with IS Management to define scope of PS projects (Oct 2026)',
 'Set internal meeting; check Sahara website for project types',
 'Define which project categories Xceed can deliver via Sahara platform',
 'Enterprise — project-based professional services buyers',
 'Project referrals and sub-contracting via Sahara platform',
 19),

('Infrastructure Security', 'Cequence Security', ARRAY['UAE','KSA'],
 'API Security, Bot Management, Application Security Testing',
 'Waiting for Xceed — Needs Sales Contact', 'waiting-xceed',
 'Application in progress; needs Xceed sales contact info to complete (Nov 2026)',
 'Provide sales contact information to complete application',
 'Complete application with sales contact details',
 'Enterprise — API-heavy organizations, banks, telcos, e-commerce',
 'API security platform license + managed AppSec service',
 20),

('Infrastructure Security', 'SupportFinity', ARRAY['UAE','KSA'],
 'IT Talent Platform, Tech Staffing',
 'Waiting for Xceed — Needs Clarification', 'waiting-xceed',
 'Initial contact; vendor interested but needs clarifications (Oct 2026)',
 'Respond with required clarifications',
 'Provide business model clarification to vendor',
 'Enterprise HR / IT teams needing tech talent',
 'Staffing/talent placement fees — not core ITO focus',
 21),

('Infrastructure Security', 'Huawei', ARRAY['UAE','KSA','Egypt'],
 'Network Infrastructure, Cloud (Huawei Cloud), Security',
 'Not Contacted', 'not-contacted',
 'Not contacted yet',
 'Assign responsible person',
 'Huawei Partner program requirements',
 'Enterprise — government & telco in KSA, UAE, Egypt',
 'Network hardware resell + cloud managed services',
 22),

('Infrastructure Security', 'Check Point ERM', ARRAY['UAE','KSA'],
 'Firewall, Endpoint Security, Cloud Security',
 'Not Contacted', 'not-contacted',
 'Not contacted yet',
 'Assign responsible person',
 'Check Point partner program',
 'Enterprise — alternative to Fortinet for large enterprise',
 'Security platform license + professional services',
 23),

('Infrastructure Security', 'Ivanti', ARRAY['UAE','KSA'],
 'Unified Endpoint Management, IT Service Management, Security',
 'Not Contacted', 'not-contacted',
 'Not contacted yet',
 'Assign responsible person',
 'Ivanti partner program requirements',
 'Mid-Market & Enterprise',
 'ITSM/UEM platform license resell',
 24),

('Infrastructure Security', 'Anomali', ARRAY['UAE','KSA'],
 'Threat Intelligence Platform, SIEM Integration',
 'Not Contacted', 'not-contacted',
 'Not contacted yet',
 'Assign responsible person',
 'Anomali MSSP partner program',
 'Enterprise SOC teams',
 'Annual threat intel platform license + managed service',
 25);
