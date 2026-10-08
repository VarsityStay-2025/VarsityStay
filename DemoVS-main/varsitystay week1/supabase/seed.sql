-- VarsityStay seed data
-- IMPORTANT: run this AFTER at least one landlord has signed up through the app,
-- and replace 'LANDLORD_UUID_HERE' with their real profiles.id (find it in
-- Table Editor -> profiles once they've signed up).

insert into properties
  (landlord_id, name, city, university, distance_minutes, monthly_rent, room_type,
   nsfas_accredited, amenities, description, verified, rating)
values
  ('LANDLORD_UUID_HERE', 'Kestell Student Village', 'Bloemfontein', 'University of the Free State',
   8, 3200, 'Single room', true, array['Wi-Fi','24/7 Security'],
   'Recently renovated single rooms with a quiet, secure courtyard. On-site laundry and a shared study lounge that''s popular during exam season.',
   true, 4.8),

  ('LANDLORD_UUID_HERE', 'Voortrekker Heights', 'Bloemfontein', 'University of the Free State',
   18, 4500, 'Shared room', true, array['Wi-Fi','24/7 Security','Parking'],
   'Spacious shared rooms with a communal kitchen and braai area. Great for students who want a social residence close to town.',
   true, 4.6),

  ('LANDLORD_UUID_HERE', 'Braamfontein Loft Studios', 'Johannesburg', 'University of the Witwatersrand',
   5, 5200, 'Studio', false, array['Wi-Fi','24/7 Security','Parking'],
   'Modern self-contained studios with fibre included. Rooftop coworking space and secure basement parking.',
   true, 4.9);

-- Repeat with more rows / more universities as needed (UP, UJ, UKZN, SU, NMU, NWU, TUT, CUT, etc.)
