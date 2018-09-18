require 'csv'

class ItemsController < ApplicationController

  before_action :find_item, except: [:index, :create, :new, :export]

  def show
    @subitems = Item.where(item: @item)
  end

  def index
    if params["commit"] == "Export"
      redirect_to controller: 'items', action: 'index', format: :csv, export: params["export"].permit!
    end


    respond_to do |format|
      format.html do
        @items = Item.all
      end

      format.csv do
        if params["export"]
          cases = params["export"]["cases"].reject(&:empty?)
        else
          cases = []
        end

        if cases.count > 0
          @items = []

          cases.each do |c|
            Item.where("case_id = #{c} and price >= #{params['export']['price']}").each{ |i| @items << i }
          end
          p @items
        else
          @items = Item.all
        end
      end
    end
  end


  def new
    @item = Item.new(case: Case.find(params[:case_id]))
    @locations = ItemType.where(case_id: @item.case).order(:name)
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to case_path(@item.case), notice: "Created item #{@item.name}"
    else
      render action: 'new'
    end
  end

  def edit
    if @item.deleted == true
      redirect_to item_path(@item), notify: "Item is still deleted!"
    end
  end

  def update
    if @item.update_attributes(item_params)
      redirect_to case_path(@item.case), notice: "Updated '#{@item.name}'"
    else
      render action: 'edit'
    end
  end

  def delete
  end

  def destroy
    @item.update_attribute(:deleted, true)
    redirect_to case_path(@item.case), notice: "Disabled '#{@item.name}' in case '#{@item.case.acronym}'"
  end

  def export
    @cases = Case.all
  end

  def clone
    item = Item.find(params[:id]).dup
    item.name = "Copy of #{item.name}"
    item.serial_number = ""

    if item.save
      redirect_to edit_item_path(item)
    else
      redirect_to item_path(Item.find(params[:id]))
    end
  end

  private

  def find_item
    @item = Item.unscoped.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :manufacturer, :model,
                                 :item_id, :case_id, :date_of_purchase,
                                 :price, :serial_number, :broken, :missing,
                                 :item_type_id, :location_item_id)
  end

end
