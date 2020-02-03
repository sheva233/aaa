# frozen_string_literal: true

class ArticlesController < ApplicationController
  def index
    @articles = Article.accepted
                  .search_by_content(params[:search]).order_list(params[:sort_by])
                  .paginate(page: params[:page]).includes([:user])
  end

  def show
    @article = Article.find(params[:id])
  end

  def edit
    @article = current_user.articles.find(params[:id])
  end

  def update
    @article = current_user.articles.find(params[:id])

    if @article.update(article_params)
      redirect_to current_user
    else
      render 'edit'
    end
  end

  def new
    @article = current_user.articles.build
  end

  def destroy
    @article = Article.find(params[:id])

    @article.destroy
    redirect_to current_user
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      redirect_to current_user
    else
      render 'new'
    end
  end

  private
  def article_params
    params.require(:article).permit(:title, :description)
  end
end
