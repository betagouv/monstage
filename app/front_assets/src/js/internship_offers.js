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

    // Enable / Disable week selection when all year long checkbox changes
    $('#all_year_long').change(function () {
        $('#internship_offer_week_ids option').prop('selected', $('#all_year_long').prop('checked'));
    });

    // By default the internship should be available all year
    $('#all_year_long').click();
});

