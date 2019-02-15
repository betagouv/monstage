var toggleMaxCandidatesVisibility = function() {
    $('#max_candidates_group').toggleClass('d-none');
};

$(document).on('turbolinks:load', function() {
    $('#internship_offer_can_be_applied_for_true').change(function() {
        toggleMaxCandidatesVisibility();
    });
    $('#internship_offer_can_be_applied_for_false').change(function() {
        toggleMaxCandidatesVisibility();
    });

    $('#all_year_long').change(function () {
        $('#internship_offer_week_ids').prop('disabled', function(i, v) { return !v; });
        $('#excluded_week_ids').prop('disabled', function(i, v) { return !v; });
    });
});

