define [
  "jquery",
  "mithril",
  "arbiter"
], ($, m, arbiter) ->
  cards = [
    "http://i.imgur.com/ircucO0.png",
    "http://i.imgur.com/1kFeLly.png",
    "http://i.imgur.com/aZ7GpiQ.png",
    "http://i.imgur.com/rOYS9Sm.png",
    "http://i.imgur.com/xmbl34o.jpg",
    "http://i.imgur.com/dVWdko8.jpg",
    "http://i.imgur.com/Dr9ekTi.gif",
    "http://i.imgur.com/DieNi7L.jpg",
    "http://i.imgur.com/a1epPuB.jpg",
    "http://i.imgur.com/4ER9a4v.jpg"
    "http://i.imgur.com/DIl4w3p.gif",
    "http://i.imgur.com/cPwAnaL.jpg",
    "http://i.imgur.com/doHAiPD.jpg",
    "http://i.imgur.com/FCKBSP0.jpg"
  ]
  focusedCard = null
  spacing = 100
  cardWidth = 168
  cardHeight = 244

  closeCards = (e) ->
    $('.memeCard').css({'right': ""})
    $('.memeCard').removeClass('open')
    $('.memeCard').removeClass('focusedCard')
    e.stopPropagation()

  openCards = () ->
    usableWidth = window.innerWidth - cardWidth * 2
    $('.memeCard').each((i) ->
      $(this).css({'right': ((usableWidth / cards.length) * i + cardWidth / 2).toString() + "px"})
      $(this).addClass('open')
    )

  clickCard = (card) ->
    (e) ->
      if e.target.classList.contains('open')
        if e.target.classList.contains('focusedCard')
          cardElement = "<img class=\"materialboxed\" src='#{card}' width='260px' style='margin: 0px -10px -5px -10px'>"
          arbiter.publish("messages/send", {text: cardElement, author: localStorage.displayName})
          closeCards(e)
        else
          $('.focusedCard').removeClass('focusedCard');
          e.target.classList.add("focusedCard")
      else
        openCards()
      e.stopPropagation()

  render = ->
    cardList = $('#card-list')
    $('body').click(closeCards)
    m.render cardList.get(0),
      for card in cards
        m "img.memeCard", {src: card, onclick: clickCard(card)}
