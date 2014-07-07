###
## <reference path="../angular-sa.js"/>
###

describe 'somewhatabstract - angular-sa', ->
  
  describe 'saNavigationGuard', ->

    Given -> module 'somewhatabstract'
  
    describe 'exists', ->
      When => inject (saNavigationGuard) =>
        @saNavigationGuard = saNavigationGuard
      Then => expect(@saNavigationGuard).toBeDefined()

  describe 'saHttpActivityInterceptor', ->
