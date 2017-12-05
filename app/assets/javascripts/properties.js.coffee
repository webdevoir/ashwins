$ ->
  $(document).on 'ajax:beforeSend', 'a.new-property', ->
    $.blockUI()

  $(document).on 'ajax:success', 'a.new-property', (data, xhr, status) ->
    $('#NewProperty').find('.modal-content').html(xhr)
    $('#NewProperty').modal()
    enable_datetimepicker()
    $.unblockUI()

  $(document).on 'ajax:beforeSend', 'form.new_property', ->
    $.blockUI()

  $(document).on 'ajax:success', 'form.new_property', (data, xhr, status) ->
    $('div.project-index').append(xhr)
    $('#NewProperty').modal('hide')
    $.unblockUI()

  $(document).on 'click', 'a.property-settings', ->
    position = $(this).position()
    $(this).parent().parent().find('#property-settings:first').toggle()
    $(this).parent().parent().find('#property-settings:first').css('left', (position.left - 100) + 'px')

  $(document).on 'click', (e) ->
    if !$(e.target).hasClass('property-settings')
      container = $("#property-settings")
      if (!container.is(e.target) and (container.has(e.target).length == 0))
        container.hide()

  $(document).on 'click', '#property_lease_percentage_rent_exist', ->
    if $(this).is(':checked')
      $(".rent-percentage-wrapper").show()
    else
      $(".rent-percentage-wrapper").hide()

  # Comments
  $(document).on 'click', '.property-comments', ->
    typeComments = $(this).attr("data-type")
    propertyId = $(this).attr("data-property")
    userId = $(this).attr("data-user")

    $.ajax
      type: "POST"
      url: "/xhr/property_comments"
      data: {id: propertyId, type: typeComments, user_id: userId}
      dataType: "html"
      success: (val) ->
        $("#comments-modal .modal-body").html(val)
        $("#comments-modal").modal('show')
      error: (e) ->
        console.log e

  $(document).on 'click', '.delete-comment', ->
    commentID = $(this).data('comment-id')
    deleteBTN = $(this)
    $.ajax
      type: "DELETE"
      url: "/comments/" + commentID
      dataType: "json"
      success: (status) ->
        deleteBTN.closest('.comment-list').remove()
        $('.property-comments-box').find('a.property-comments').text('Comments(' + $('.comments-wrapper .comment-list').length + ')')
      error: (e) ->
        console.log e

  $(document).on 'click', '.edit-comment', ->
    commentID = $(this).data('comment-id')
    $.ajax
      type: "GET"
      url: "/comments/" + commentID + '/edit'
      dataType: "json"
      success: (data) ->
        $(".comment-editor .compose-header span.title").text('Edit Comment')
        $(".comment-editor #comment-content").attr("data-comment-id", data.id)
        $('#comments-modal').modal('hide')

        $('.comment-editor #comment-content').summernote('code', data.comment)
        $('.comment-editor').slideToggle()
      error: (e) ->
        console.log e

  tmpComments = 0
  $(document).on 'click', '.property-add-comment', ->
    tmpComments = $(this).prev()
    $(".comment-editor #comment-content").val('')
    $(".comment-editor #comment-content").attr("data-comment-id", '')
    $(".comment-editor #comment-content").attr("data-type", $(this).attr("data-type"))
    $(".comment-editor #comment-content").attr("data-user", $(this).attr("data-user"))
    $(".comment-editor #comment-content").attr("data-property", $(this).attr("data-property"))

    $('.comment-editor #comment-content').summernote('code', '')
    $('.comment-editor').slideToggle()

  $(document).on 'click', '.compose-close', ->
    $('.comment-editor').slideToggle()

  $(document).on 'click', '#save-comment', ->
    if !$(".comment-editor #comment-content").attr("data-comment-id")
      typeComments = $(".comment-editor #comment-content").attr("data-type")
      propertyId = $(".comment-editor #comment-content").attr("data-property")
      userId = $(".comment-editor #comment-content").attr("data-user")

      $.ajax
        type: "POST"
        url: "/xhr/add_property_comment"
        data: {id: propertyId, type: typeComments, user_id: userId, comment: $("#comment-content").val()}
        dataType: "json"
        success: (response) ->
          console.log response.status
          tmpComments.text('Comments(' + response.length + ')')
          $('.comment-editor').slideToggle()
        error: (e) ->
          console.log e
    else
      commentID = $(".comment-editor #comment-content").attr("data-comment-id")
      $.ajax
        type: "PUT"
        url: "/comments/" + commentID
        data: { comment: $("#comment-content").val() }
        dataType: "json"
        success: (response) ->
          console.log response.status
          $('.comment-editor').slideToggle()
        error: (e) ->
          console.log e

  # Inline EDIT
  $(document).on 'mouseover', '.property-heading-index', ->
    id = $(this).attr('data-id')
    $(document).find('.property-heading-index').editable '/properties/update/'+id,
      name: 'title'
      tooltip: 'click to edit..'
      indicator: 'Saving....'
      onblur : 'submit'
      callback: ->
  # fetch_action_checklist(pid)

  $(document).on 'mouseover', '.property-description-index', ->
    id = $(this).attr('data-id')
    $(document).find('.property-description-index').editable '/properties/update/'+id,
      type: 'textarea'
      name: 'description'
      tooltip: 'click to edit..'
      indicator: 'Saving....'
      onblur : 'submit'
      callback: ->


  $(document).on 'click', '.title', ->
    url = $(this).parent().attr('url')
    window.location.href = url if url.length > 0

  $(document).on 'ifChanged', '#property_location_street_address_from_county_tax_authorities_is', ->
    if $(this).is(':checked')
      $(document).find('#location_street_address_from_county_tax_authorities').show()
    else
      $(document).find('#location_street_address_from_county_tax_authorities').hide()

  $(document).on 'click', '.title', ->
    url = $(this).parent().attr('url')
    window.location.href = url if url.length > 0
  $(document).on 'click', 'input#property_rent_increase_in_base_term_status', ->
    if this.checked
      $(document).find('#rent_increase_in_base_term').show()
    else
      $(document).find('#rent_increase_in_base_term').hide()

  $(document).on 'click', '.title', ->
    url = $(this).parent().attr('url')
    window.location.href = url if url.length > 0
  $(document).on 'click', 'input#property_preliminary_term_status', ->
    if this.checked
      $(document).find('#preliminary_term').show()
    else
      $(document).find('#preliminary_term').hide()

  $(document).on 'click', '.title', ->
    url = $(this).parent().attr('url')
    window.location.href = url if url.length > 0
  $(document).on 'click', 'input#property_optional_extensions_status', ->
    if this.checked
      $(document).find('#optional_extensions').show()
    else
      $(document).find('#optional_extensions').hide()

  setTitleValue = ->
    if $('#property_location_city').val().length > 0
      $(document).find('.tilte_basic_info').show()
      property_title = $("#property_tenant_id option[value='" + $('#property_tenant_id').val() + "']").text().trim() + ', ' + $('#property_location_city').val()
      $('#property_title').val(property_title)

  titleHideShow = ->
    if $('#property_location_city').length > 0 && $('#property_location_city').val().length > 0
      $(document).find('.tilte_basic_info').show()
      setTitleValue()
    else
      #$(document).find('.tilte_basic_info').hide()
    return

  $(document).ready ->
    titleHideShow()

  $(document).on 'keyup', '#property_location_city', ->
    val = $('#property_location_city').val()
    upperval = val.substr(0, 1).toUpperCase() + val.substr(1)
    $('#property_location_city').val(upperval)
    titleHideShow()

  $(document).on 'click', '.entity_owner', ->
    if this.value == "true"
      $('#person_owner').show()
      $('#entity_owner').hide()
    else
      $('#person_owner').hide()
      $('#entity_owner').show()

  $(document).on 'ifChecked', '#property_owner_person_is_1', ->
    #alert "is person"
    $(document).find('div.sale-tr-pr-detail').show()
    $(document).find('div.sale-tr-et-detail').hide()
    $(document).find('div.concurrent_estates_popup').hide()

  $(document).on 'ifChecked', '#property_owner_person_is_2', ->
    #alert "is a entity"
    $(document).find('div.sale-tr-pr-detail').hide()
    $(document).find('div.sale-tr-et-detail').show()
    $(document).find('div.concurrent_estates_popup').hide()

  $(document).on 'ifChecked', '#property_owner_person_is_0', ->
    #alert "is not a person"
    $(document).find('div.sale-tr-pr-detail').hide()
    $(document).find('div.sale-tr-et-detail').hide()
    $(document).find('div.concurrent_estates_popup').hide()

  $(document).on 'blur', '#property_location_city', ->
    $("#property-readonly-city").val($(this).val())

  $(document).on 'ifChecked', '#property_owner_person_is_0', ->
    #alert "is not a person"
    $(document).find('div.sale-tr-pr-detail').hide()
    $(document).find('div.sale-tr-et-detail').hide()
    $(document).find('div.concurrent_estates_popup').show()

  $(document).on "click", "a.ownership-form-new-entity", ->
    if $('#status_poperty')[0].value == "Purchased"
      url = '/clients/new'
    else
      url = '/contacts/new'
    $(this).closest('.autocomplete').hide()
    $.ajax
      type: "get"
      url: url
      dataType: "html"
      success: (val) ->
        $("div#OwnershipFormNewEntity").find(".model-body").find(".OwnershipFormNewEntity").html(val)
      error: (e) ->
        console.log e
    $("div#OwnershipFormNewEntity").modal()


  $(document).on 'click', "a.resource-form-entity-pick-form-list", ->
    url = "/properties/xhr_list_dropdown"
    params = {person: $('.entity_owner')[0].checked, id: $('#property_id')[0].value }
    $.ajax
      type: "get"
      url: url
      data: params
      dataType: "html"
      success: (val) ->
        $("div#OwnershipFormNewEntity").find(".model-body").find(".OwnershipFormNewEntity").html(val)
      error: (e) ->
        console.log e
    $("div#OwnershipFormNewEntity").modal()

  $(document).on 'click', ".ind-entity-popup", ->
    $("div#OwnershipFormNewEntity").modal('hide')
    if $(this).data('klass') == "Person"
      $('#owner_entity_dropown_selection').html('<input autocomplete="off" id="property_owner_person_id" name="property[owner_person_id]" type="hidden">')
      $('#property_owner_person_id').val($(this).data('id'))
      $('#member_entity').val($(this).data('name'))
    else
      $('#owner_entity_dropown_selection').html('<input autocomplete="off" id="property_owner_entity_id" name="property[owner_entity_id]" type="hidden">')
      $('#property_owner_entity_id').val($(this).data('id'))
      $('#member_entity').val($(this).data('name'))

  $(document).on 'click', "select#rent_table_version", ->
    propertyId = $(this).data("id")
    selectedVersion = $(this).val()

    $.ajax
      type: "POST"
      url: "/xhr/get_rent_table"
      data: { id: propertyId, version: selectedVersion }
      dataType: "html"
      success: (val) ->
        $(document).find("#rent-table-wrapper").html(val)
      error: (e) ->
        console.log e

  $(document).on 'change', "select[id^='filter_rent_table_by_date']", ->
    year = $('#filter_rent_table_by_date__1i').val()
    month = $('#filter_rent_table_by_date__2i').val()
    day = $('#filter_rent_table_by_date__3i').val()
    propertyId = $(this).data("id")

    $.ajax
      type: "POST"
      url: "/xhr/get_all_rent_by_date"
      data: { id: propertyId, year: year, month: month, day: day }
      dataType: "html"
      success: (val) ->
        $(document).find("#rent-table-wrapper").html(val)
      error: (e) ->
        console.log e

  autoPopulateCapRate = ->
    currentRent = $("#property_current_rent").val().replace(/\,/g, "")
    propertyPrice = $("#property_price").val().replace(/\,/g, "")

    if isNaN(propertyPrice) || isNaN(currentRent)
      $("#property_cap_rate").val("")
    else
      $("#property_cap_rate").val(parseFloat(currentRent)/parseFloat(propertyPrice)*100)

  $(document).on 'keyup', '#property_price', ->
    autoPopulateCapRate()

  $(document).on 'keyup', '#property_current_rent', ->
    autoPopulateCapRate()

  $(document).on 'click', '.new-tenant-button', ->
    $("#new-tenant .error-message").hide()
    $("#new-tenant #new-tenant-name").val("")
    $("#new-tenant").modal()

  $(document).on 'click', '.rating label', ->
    $selector = $(this).prev()
    $action = () -> $selector.click()
    setTimeout($action, 100)

  $(document).on 'click', '#save-new-tenant', ->
    newTenantName = $("#new-tenant-name").val()

    $.ajax
      type: "POST"
      url: "/xhr/add_new_tenant"
      data: {name: newTenantName}
      dataType: "json"
      success: (response) ->
        if (response.status == "success" && response.id)
          $("#property_tenant_id").append("<option value='" + response.id + "'>" + newTenantName + "</option>")
          $("#new-tenant").modal('hide')
        else
          $("#new-tenant .error-message").show()
      error: (e) ->
        console.log e

  $(document).on 'click', '#lease_rent_table', ->
    if $(document).find('#rent-table-wrapper').length == 0
      $.notify "You can't write the rent table because there's no rent", "info"

  $(document).on 'ifChecked', '#use_current_rent_true', ->
    console.log 'Display current rent from user input'

  $(document).on 'ifChecked', '#use_current_rent_false', ->
    console.log 'Calculate current rent from base rent and other terms'

  $(document).on "click", "a.delete-property", ->
    key = $(this).attr 'data-key'

    $.ajax
      type: "POST"
      url: "/xhr/properties_delete_warning"
      data: {key: key}
      dataType: "html"
      success: (val) ->
        $("#md-delete-property .modal-body").html(val)
        $("#md-delete-property").modal 'show'
        $("#md-delete-property .delete-property-yes").attr 'data-key', key
      error: (e) ->
        console.log e

  $(document).on "click", "a.delete-property-yes", ->
    key = $(this).attr 'data-key'
    $(this).attr("disabled", "disabled")

    $.ajax
      type: "DELETE"
      url: "/properties/" + key
      dataType: "json"
      success: (val) ->
        if val.success == true
          $("#md-delete-property").modal 'hide'
          window.location.href = '/properties'
      error: (e) ->
        console.log

  $(document).on 'click', '#lease_tab li a', ->
    curPropertyId = $("#property_id").val()
    selectedLeaseTabId = $(this).attr("href").substring(1)

    if parseInt(curPropertyId) > 0
      $.ajax
        type: "POST"
        url: "/xhr/save_property_lease_tab"
        data: { id: curPropertyId, last_sub_tab: selectedLeaseTabId }
        dataType: "json"
        success: (val) ->
          console.log val
        error: (e) ->
          console.log e

  # make fixed tab while scrolling
  $(document).on 'shown.bs.tab', '#lease_tab a[data-toggle="tab"]', ->
    $('.mask_content').each ->
      if $(this).is(':visible')
        height = $(window).height() - $(this).offset().top - 5
        if height > 50
          $(this).css('overflow-y', 'scroll')
          $(this).height(height)
