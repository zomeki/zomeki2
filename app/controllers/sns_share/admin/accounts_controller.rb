class SnsShare::Admin::AccountsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = SnsShare::Content::Account.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    @item = @content.accounts.find(params[:id]) if params[:id].present?
  end

  def index
    @items = @content.accounts.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
  end

  def edit
  end

  def update
    @item.attributes = account_params
    _update @item
  end

  def logout
    @item.update_attributes(uid: nil,
                            info_nickname: nil,
                            info_name: nil,
                            info_image: nil,
                            info_url: nil,
                            credential_token: nil,
                            credential_expires_at: nil,
                            credential_secret: nil,
                            facebook_page_options: nil,
                            facebook_page: nil)
    redirect_to sns_share_accounts_path(@content), notice: 'ログアウトしました。'
  end

  private

  def account_params
    if params[:item]
      params[:item].permit(:facebook_token, :facebook_page)
    else
      {}
    end
  end
end
