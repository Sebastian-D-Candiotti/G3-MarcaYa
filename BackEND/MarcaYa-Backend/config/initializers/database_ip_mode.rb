# frozen_string_literal: true

# Force IPv4 for PostgreSQL connections.
# Supabase resolves its hostname to an IPv6 address that Render cannot reach.
# libpq respects PGPREFER_IP_MODE; setting it to 4 makes it try IPv4 first.
ENV["PGPREFER_IP_MODE"] ||= "4"
