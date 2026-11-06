-- iyodriver · only a submitted application can be approved. Approving an empty one left drivers
-- "approved" with no vehicle, so they could never go online.

create or replace function public.admin_decide_driver(
  p_driver_id uuid,
  p_approve boolean,
  p_note text default null,
  p_reject_document public.document_type default null
)
returns public.driver_profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_admin uuid := public._require_admin();
  d public.driver_profiles;
begin
  select * into d from public.driver_profiles where user_id = p_driver_id for update;
  if not found then
    raise exception 'driver_not_found' using errcode = 'P0002';
  end if;

  if p_approve then
    if d.verification_status <> 'under_review' then
      raise exception 'application_not_submitted' using errcode = 'P0001';
    end if;
    if exists (
      select 1 from public.driver_documents where driver_id = p_driver_id and status = 'rejected'
    ) then
      raise exception 'documents_rejected' using errcode = 'P0001';
    end if;
    update public.driver_documents set status = 'approved', reviewed_at = now(), reviewed_by = v_admin
    where driver_id = p_driver_id and status = 'pending';
    update public.vehicles set status = 'approved', is_active = true, reviewed_at = now(), reviewed_by = v_admin
    where driver_id = p_driver_id and status = 'pending';
    update public.driver_profiles set
      verification_status = 'approved', approved_at = now(), reviewed_at = now(),
      reviewed_by = v_admin, review_notes = nullif(trim(p_note), '')
    where user_id = p_driver_id returning * into d;
  else
    if coalesce(trim(p_note), '') = '' then
      raise exception 'note_required' using errcode = 'P0001';
    end if;
    if p_reject_document is not null then
      update public.driver_documents set
        status = 'rejected', rejection_reason = left(p_note, 300), reviewed_at = now(), reviewed_by = v_admin
      where driver_id = p_driver_id and type = p_reject_document;
    end if;
    update public.driver_profiles set
      verification_status = 'action_needed', reviewed_at = now(), reviewed_by = v_admin,
      review_notes = left(p_note, 1000)
    where user_id = p_driver_id returning * into d;
  end if;
  return d;
end;
$$;
