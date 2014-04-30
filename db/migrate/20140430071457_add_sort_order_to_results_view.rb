class AddSortOrderToResultsView < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-END
      DROP VIEW results_feed_view;
      CREATE VIEW results_feed_view AS
        SELECT cr.precinct_id, cor.contest_id, CAST(NULL AS NUMERIC) referendum_id, co.office contest,
               ca.name candidate, p.name party, votes, ca.sort_order
        FROM   candidate_results cr, contest_results cor, contests co,
               candidates ca, parties p
        WHERE  cor.id=cr.contest_result_id AND
               co.id=cor.contest_id AND
               ca.id=cr.candidate_id AND
               p.id = ca.party_id

        UNION ALL

        SELECT brr.precinct_id, NULL, cor.referendum_id, re.title, br.name, '', votes, br.sort_order
        FROM   ballot_response_results brr, contest_results cor, referendums re, ballot_responses br
        WHERE  cor.id=brr.contest_result_id AND
               br.id=brr.ballot_response_id AND
               re.id=cor.referendum_id

        UNION ALL

        SELECT cor.precinct_id, cor.contest_id, NULL, co.office contest, v.candidate, '', 0, v.sort_order
        FROM   contest_results cor, contests co, (SELECT 'OVERVOTES' candidate, 9999 sort_order UNION ALL SELECT 'UNDERVOTES', 9998) v
        WHERE  co.id=cor.contest_id

        UNION ALL

        SELECT cor.precinct_id, NULL, cor.referendum_id, re.title, v.candidate, '', 0, v.sort_order
        FROM   contest_results cor, referendums re, (SELECT 'OVERVOTES' candidate, 9999 sort_order UNION ALL SELECT 'UNDERVOTES', 9998) v
        WHERE  re.id=cor.referendum_id;
    END
  end

  def down
    ActiveRecord::Base.connection.execute <<-END
      DROP VIEW results_feed_view;
      CREATE VIEW results_feed_view AS
        SELECT cr.precinct_id, cor.contest_id, CAST(NULL AS NUMERIC) referendum_id, co.office contest,
               ca.name candidate, p.name party, votes
        FROM   candidate_results cr, contest_results cor, contests co,
               candidates ca, parties p
        WHERE  cor.id=cr.contest_result_id AND
               co.id=cor.contest_id AND
               ca.id=cr.candidate_id AND
               p.id = ca.party_id

        UNION ALL

        SELECT brr.precinct_id, NULL, cor.referendum_id, re.title, br.name, '', votes
        FROM   ballot_response_results brr, contest_results cor, referendums re, ballot_responses br
        WHERE  cor.id=brr.contest_result_id AND
               br.id=brr.ballot_response_id AND
               re.id=cor.referendum_id

        UNION ALL

        SELECT cor.precinct_id, cor.contest_id, NULL, co.office contest, v.candidate, '', 0
        FROM   contest_results cor, contests co, (SELECT 'OVERVOTES' candidate UNION ALL SELECT 'UNDERVOTES') v
        WHERE  co.id=cor.contest_id

        UNION ALL

        SELECT cor.precinct_id, NULL, cor.referendum_id, re.title, v.candidate, '', 0
        FROM   contest_results cor, referendums re, (SELECT 'OVERVOTES' candidate UNION ALL SELECT 'UNDERVOTES') v
        WHERE  re.id=cor.referendum_id;
    END
  end
end
