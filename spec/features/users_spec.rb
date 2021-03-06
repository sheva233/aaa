# frozen_string_literal: true

require 'rails_helper'
RSpec.feature 'Users', type: :feature do
  let(:current_user) { create(:user, password: 'caplin') }
  let!(:article) { create(:article, title: 'created cable', description: 'update', user_id: current_user.id) }

  before :each do
    user = create(:user, email: 'activebridge@active-bridge.com', nickname: 'pamela', password: 'sonars', id: 300)
    admin = create(:user, email: 'admino@activebridge', nickname: 'admod', role: :admin, password: 'admind', id: 302)
    create(:user)
  end

  context 'only admin and owner can select user for edit' do
    scenario 'check if admin' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      article.destroy
      click_on 'Create new article'
      within('form') do
        fill_in 'article_title', with: 'Active bridge'
        fill_in 'article_description', with: 'Active bridge description'
        find('#article_user_ids').find(:xpath, 'option[1]').select_option
        find('#article_user_ids').find(:xpath, 'option[2]').select_option
        find('#article_user_ids').find(:xpath, 'option[3]').select_option
      end
      click_on 'Create Article'
      visit home_path
      click_on 'Logout'
      visit user_session_path
      within('form') do
        fill_in 'Email', with: 'admino@activebridge'
        fill_in 'Password', with: 'admind'
      end
      click_button 'Log in'
      find('.current-user-art').first(:link, 'Show user').click
      click_on 'Edit article'
      within('form') do
        fill_in 'article_title', with: 'Active bridge edited'
        find('#article_user_ids').find(:xpath, 'option[1]').unselect_option
      end
      click_on 'Update Article'
      a = Article.where(user_id: current_user.id)
      b = a.last.user_ids
      expect(b.count).to eq 2
      click_on 'Edit article'
      within('form') do
        fill_in 'article_title', with: 'Active bridge edited'
        find('#article_user_ids').find(:xpath, 'option[1]').select_option
      end
      click_on 'Update Article'
      b = a.last.user_ids
      expect(b.count).to eq 3
      visit home_path
      click_on 'Logout'
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      find('.current-user-art').first(:link, 'Show user').click
      click_on 'Edit article'
      within('form') do
        fill_in 'article_title', with: 'Active bridge'
        find('#article_user_ids').find(:xpath, 'option[2]').unselect_option
      end
      click_on 'Update Article'
      visit home_path
      click_on 'Logout'
      visit user_session_path
      within('form') do
        fill_in 'Email', with: 'admino@activebridge'
        fill_in 'Password', with: 'admind'
      end
      click_button 'Log in'
      find('.current-user-art').first(:link, 'Show user').click
      expect(page).not_to have_content('Article title')
      visit home_path
      click_on 'Logout'
      visit user_session_path
      within('form') do
        fill_in 'Email', with: 'activebridge@active-bridge.com'
        fill_in 'Password', with: 'sonars'
      end
      click_button 'Log in'
      find('.current-user-art').first(:link, 'Show user').click
      expect(page).to have_content('Article title')
      click_on 'Edit article'
      expect(page).not_to have_content('Select user for grant access:')
      within('form') do
        fill_in 'article_title', with: 'Active bridge edited'
      end
      click_on 'Update Article'
    end
  end

  context 'join table articles1' do
    scenario 'check select' do
      # loggin in
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      article.destroy
      click_on 'Create new article'
      within('form') do
        fill_in 'article_title', with: 'Active bridge'
        fill_in 'article_description', with: 'Active bridge description'
        find('#article_user_ids').find(:xpath, 'option[2]').select_option
        find('#article_user_ids').find(:xpath, 'option[3]').select_option
      end
      click_on 'Create Article'
      a = Article.where(user_id: current_user.id)
      b = a.last.user_ids
      # checking for user ids count
      expect(b.count).to eq 2
      click_on 'Edit article'
      # updating user ids count to 3
      within('form') do
        fill_in 'article_title', with: 'Active bridge'
        fill_in 'article_description', with: 'Active bridge description'
        find('#article_user_ids').find(:xpath, 'option[1]').select_option
      end
      click_on 'Update Article'
      b = a.last.user_ids
      expect(b.count).to eq 3
      visit home_path
      click_on 'Logout'
      # log in by new user to check user permission
      visit user_session_path
      within('form') do
        fill_in 'Email', with: 'activebridge@active-bridge.com'
        fill_in 'Password', with: 'sonars'
      end
      click_button 'Log in'
      click_on 'Show user'
      expect(page).to have_content('Active bridge description')
      # check if user can edit article created by another user
      click_on 'Edit article'
      within('form') do
        fill_in 'article_title', with: 'Active bridge233'
        fill_in 'article_description', with: 'Active bridge2description'
      end
      click_on 'Update Article'
      expect(page).to have_content('Active bridge2description')
      visit home_path
      click_on 'Logout'
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      click_on 'Show user'
      expect(page).to have_content('Active bridge2description')
      expect(page).to have_content('Active bridge233')
      click_on 'Edit article'
      within('form') do
        fill_in 'article_title', with: 'Active bridge'
        fill_in 'article_description', with: 'Active bridge description'
        find('#article_user_ids').find(:xpath, 'option[1]').unselect_option
      end
      click_on 'Update Article'
      b = a.last.user_ids
      expect(b.count).to eq 2
      visit home_path
      click_on 'Logout'
      visit user_session_path
      within('form') do
        fill_in 'Email', with: 'activebridge@active-bridge.com'
        fill_in 'Password', with: 'sonars'
      end
      click_button 'Log in'
      click_on 'Show user'
      expect(page).not_to have_content('Article title:')
    end
  end

  context 'signs me in' do
    scenario 'should be successful' do
      article.destroy
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      create(:article, title: 'test title', description: 'test description', user_id: current_user.id)
      expect(page).to have_content('Signed in successfully.')
      expect(page).to have_content('Show user', count: 1)
      find(:xpath, "//a[@href='/users/#{current_user.slug}']").click
      expect(page).to have_content(current_user.email)
      expect(page).to have_content('test title')
      expect(page).to have_current_path(user_path(current_user.slug))
    end
  end

  context 'check users view of other users' do
    scenario 'check user' do
      visit home_path
      visit '/users/admod'
      expect(page).to have_current_path(home_path)
    end
    scenario 'check loggin admin' do
      visit home_path
      visit user_session_path
      within('form') do
        fill_in 'Email', with: 'admino@activebridge'
        fill_in 'Password', with: 'admind'
      end
      click_button 'Log in'
      visit '/users/pamela'
      expect(page).to have_content('User nickname: pamela')
      expect(page).to have_current_path('/users/pamela')
    end
    scenario 'user cant view blank user' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      visit '/users/pamela'
      expect(page).to have_current_path(home_path)
    end
    scenario 'check active admin permission for admin' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: 'admino@activebridge'
        fill_in 'Password', with: 'admind'
      end
      click_button 'Log in'
      visit '/admin'
      expect(page).to have_current_path('/admin')
      expect(page).to have_content('Dashboard')
    end
    scenario 'check active admin permission for user' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      visit '/admin'
      expect(page).not_to have_current_path('/admin')
      expect(page).not_to have_content('Dashboard')
      expect(page).to have_current_path(home_path)
    end
  end

  context 'log in with social network' do
    scenario 'login with facebook' do
      mock_auth_hash_fb
      visit home_path
      visit '/users/auth/facebook/callback'
      expect(page).to have_content('Gaius Baltar')
      expect(page).to have_content('Login success')
    end
    scenario 'failure login to fb' do
      dont_sign_in_fb
      visit home_path
      visit '/users/auth/facebook/callback'
      expect(page).to have_content('Sign in w/ facebook')
      expect(page).to have_content('Login failed')
    end
    scenario 'login with google' do
      mock_auth_hash_google
      visit home_path
      visit '/users/auth/google_oauth2/callback'
      expect(page).to have_content('Gaius Baltar')
      expect(page).to have_content('Login success')
    end
    scenario 'failure login to google' do
      dont_sign_in_google
      visit home_path
      visit '/users/auth/google_oauth2/callback'
      expect(page).to have_content('Sign in w/ google')
      expect(page).to have_content('Login failed')
    end
    scenario 'user persisted? facebook' do
      mock_auth_hash_fb(true)
      visit home_path
      visit '/users/auth/facebook/callback'
      expect(page).to have_current_path('/users/sign_up')
      expect(page).to have_content('Sign up')
    end
    scenario 'user persisted? google' do
      mock_auth_hash_google(true)
      visit home_path
      visit '/users/auth/google_oauth2/callback'
      expect(page).to have_current_path('/users/sign_up')
      expect(page).to have_content('Sign up')
    end
  end

  context 'mailer' do
    scenario 'confirm user' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      click_on 'Confirm user'
      within('.field') do
        fill_in 'Email', with: current_user.email
      end
      click_on 'Resend confirmation instructions'
      open_email(current_user.email)
    end
  end

  context 'settings controller' do
    scenario 'new color settings(update fail)' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      click_on 'Choose color theme'
      within('form') do
        find(:xpath, "//input[@id='setting_header_color']").set '#e2e2c3'
        find(:xpath, "//input[@id='setting_background_color']").set '#f4f7de'
        find(:xpath, "//input[@id='setting_information_color']").set '#c8c8c8'
        click_on 'Create Setting'
      end
      click_on 'Choose color theme'
      expect(page).to have_field('setting[header_color]', with: '#e2e2c3')
      expect(page).to have_field('setting[background_color]', with: '#f4f7de')
      expect(page).to have_field('setting[information_color]', with: '#c8c8c8')
      within('form') do
        find(:xpath, "//input[@id='setting_header_color']").set '#939382'
        find(:xpath, "//input[@id='setting_background_color']").set '#b9c373'
        find(:xpath, "//input[@id='setting_information_color']").set '#baa6a6'
        click_on 'Update Setting'
      end
      click_on 'Choose color theme'
      expect(page).to have_field('setting[header_color]', with: '#939382')
      expect(page).to have_field('setting[background_color]', with: '#b9c373')
      expect(page).to have_field('setting[information_color]', with: '#baa6a6')
      page.execute_script("$('#setting_header_color')[0].type = 'text'")
      page.execute_script("$('#setting_header_color')[0].value = null")
      click_on 'Update Setting'
      expect(page).to have_current_path("/settings/#{current_user.setting.id}")
    end
    scenario 'new settings fail' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      click_on 'Choose color theme'
      page.execute_script("$('#setting_header_color')[0].type = 'text'")
      page.execute_script("$('#setting_header_color')[0].value = null")
      click_on 'Create Setting'
      expect(page).to have_current_path('/settings')
    end
  end

  context 'check user name' do
    scenario 'user name = email' do
      expect(current_user.name).to eq(current_user.email)
    end
  end

  context 'find articles' do
    scenario 'should find title' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      click_on 'Create new article'
      within('form') do
        fill_in 'article_title', with: 'Active bridge'
        fill_in 'article_description', with: 'Active bridge description'
      end
      find('input[name="commit"]').click
      expect(page).to have_content('Active bridge')
      click_on 'Back'
      click_on 'Create new article'
      within('form') do
        fill_in 'article_title', with: 'Sheva'
        fill_in 'article_description', with: 'Sheva description'
      end
      find('input[name="commit"]').click
      expect(page).to have_content('Sheva')
      expect(page).to have_content('Sheva description')
      first('.accepted-articles-current-user').click_link('Edit article')
      within('form') do
        fill_in 'article_title', with: 'Sheva123'
        fill_in 'article_description', with: 'Sheva description123'
      end
      find('input[name="commit"]').click
      expect(page).to have_content('Sheva123')
      expect(page).to have_content('Edit article', count: 3)
      first('.accepted-articles-current-user').click_link('Edit article')
      within('form') do
        fill_in 'article_title', with: 'Active bridge'
      end
      find('input[name="commit"]').click
      expect(page).to have_content('Edit article')
      visit home_path
      click_on 'Create new article'
      within('form') do
        fill_in 'article_title', with: 'Active bridge'
        fill_in 'article_description', with: 'Sheva description'
      end
      find('input[name="commit"]').click
      expect(page).to have_content('Create new article')
      visit home_path
      click_on 'Show user'
      expect(page).to have_content('Article title', count: 3)
      page.accept_confirm do
        first('.accepted-articles-current-user').click_link('Delete article')
      end
      expect(page).to have_content('Article title', count: 2)
    end

    scenario 'sorting articles with js' do
      create(:article, title: 'bidddge!!!', user_id: current_user.id)
      create(:article, title: 'brige!!!', user_id: current_user.id)
      create(:article, title: 'briddd!!', user_id: current_user.id)
      create(:article, title: 'bridddg!!', user_id: current_user.id)
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      visit articles_path
      find('#sort_by').click
      find('#sort_by option', text: 'Sort by Title').click
      expect(page).to have_content('Sort by Title')
      find('#sort_by').click
      find('#sort_by option', text: 'Sort by Description').click
      expect(page).to have_content('Sort by Description')
      find('#sort_by').click
      find('#sort_by option', text: 'Sort by User email').click
      expect(page).to have_content('Sort by User email')
      find('#sort_by').click
      first('#sort_by option').click
      expect(page).to have_content('Sort by')
    end

    scenario 'check search form' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      create(:article, title: 'bidddge!!!', user_id: current_user.id)
      create(:article, title: 'brige!!!', user_id: current_user.id)
      create(:article, title: 'briddd!!', user_id: current_user.id)
      visit articles_path
      within('form') do
        fill_in 'search', with: 'bidddge!!!'
      end
      find('input[value="Search"]').click
      expect(page).to have_css('.accepted-articles', count: 1)
    end

    scenario 'active cable update' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      create(:article, title: 'active cable', description: 'create then update', user_id: current_user.id)
      find(:xpath, "//a[@href='/users/#{current_user.slug}']").click
      expect(page).to have_content('created cable')
      article.update(title: 'active bridge')
      expect(page).not_to have_content('created cable')
      expect(page).to have_content('active bridge')
      expect(page).to have_content('Edit article', count: 2)
      article.destroy
      expect(page).to have_css('.accepted-articles-current-user', count: 1)
      expect(page).not_to have_css('.accepted-articles-current-user', count: 2)
      create(:article, title: 'activs dbdb', description: 'coverage 90%', user_id: current_user.id)
      expect(page).to have_css('.accepted-articles-current-user', count: 2)
      expect(page).not_to have_css('.accepted-articles-current-user', count: 3)
    end
  end

  context 'react page test' do
    scenario 'set nickname and current user' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      create(:article, title: 'bidddge!!!', user_id: current_user.id)
      create(:article, title: 'brige!!!', user_id: current_user.id)
      create(:article, title: 'briddd!!', user_id: current_user.id)
      create(:article, title: 'bridddg!!', user_id: current_user.id)
      visit hello_world_path
      within('form') do
        fill_in 'name', with: 'active-bridge'
      end
      expect(page).to have_content('active-bridge')
      find('input[value="submit"]').click
      expect(page).to have_content('active-bridge')
      expect(page).not_to have_content('Stranger')
      expect(page).to have_content('Title:', count: 5)
      find('input[type="checkbox" i]').click
      expect(page).to have_content('Title:', count: 5)
      expect(page).to have_content(current_user.email, count: 5)
    end

    scenario 'Created at and Pagination' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      create(:article, title: 'bidddge!!!', user_id: current_user.id)
      create(:article, title: 'brige!!!', user_id: current_user.id)
      create(:article, title: 'briddd!!', user_id: current_user.id)
      create(:article, title: 'bridddg!!', user_id: current_user.id)
      create(:article, title: 'bridddgeee!!', user_id: current_user.id)
      visit hello_world_path
      a = page.find('.allArticles')
      b = a.find('.articleClass:nth-child(1) p.articleCreatedTime').text
      c = a.find('.articleClass:nth-child(2) p.articleCreatedTime').text
      expect(b).to be > c
      find('.selectForSort').click
      find('.selectForSort option', text: 'Sort by description').click
      find('.selectForSort').click
      find('.selectForSort option', class: 'sortBlank').click
      expect(page).to have_current_path('/hello_world?sortingValue=blank&page=1&user_articles=false')
      within('.ui.large.pagination.menu') do
        find('.item', text: '2').click
      end
      find('input[type="checkbox" i]').click
      within('.ui.large.pagination.menu') do
        find('.item', text: '2').click
      end
      expect(page).to have_content('Title:', count: 1)
      expect(page).to have_current_path('/hello_world?sortingValue=blank&page=2&user_articles=true')
    end

    scenario 'check sorting methods: title, description' do
      visit user_session_path
      within('form') do
        fill_in 'Email', with: current_user.email
        fill_in 'Password', with: 'caplin'
      end
      click_button 'Log in'
      create(:article, title: 'bidddge!!!', user_id: current_user.id)
      create(:article, title: 'brige!!!', user_id: current_user.id)
      create(:article, title: 'briddd!!', user_id: current_user.id)
      create(:article, title: 'bridddg!!', user_id: current_user.id)
      create(:article, title: 'bridddgeee!!', user_id: current_user.id)
      visit hello_world_path
      find('.selectForSort').click
      find('.selectForSort option', text: 'Sort by title').click
      expect(page).to have_current_path('/hello_world?sortingValue=title&page=1&user_articles=false')
      a = page.find('.allArticles')
      b = a.find('.articleClass:nth-child(1) p.articleTitle').text
      c = a.find('.articleClass:nth-child(2) p.articleTitle').text
      d = a.find('.articleClass:nth-child(3) p.articleTitle').text
      expect(b).to be < c
      expect(d).to be > c
      expect(b).to be < d
      find('.selectForSort').click
      find('.selectForSort option', text: 'Sort by description').click
      expect(page).to have_current_path('/hello_world?sortingValue=description_length&page=1&user_articles=false')
    end
  end
end
