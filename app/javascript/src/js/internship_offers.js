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
});

