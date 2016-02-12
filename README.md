README
======

Details on server setup can be found here.


PostgreSQL
----------

* PostgreSQL 9.1 -
  Installation instructions: https://help.ubuntu.com/community/PostgreSQL
* PostGIS 2.0 -
  Installation instructions: http://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS20Ubuntu1304

* Run the statement to allow 'enrs' user to access geo columns:

      GRANT SELECT ON public.geometry_columns TO enrs;

* Run the database migrations and seed the database:

      rake db:migrate
      rake db:seed

NGINX
-----

* Add to server configuration:

      client_max_body_size 200M;
