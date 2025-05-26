import { LightningElement, track, api, wire } from 'lwc';
import { CartAdapter, addItemToCart } from 'commerce/cartApi';
import { trackAddProductToCart } from 'commerce/activitiesApi';
import validateCart from '@salesforce/apex/ValidateCart.validateCart';
import { ProductInventoryLevelsAdapter } from 'commerce/productApi'; // Importa el adaptador específico

export default class AddToCartButton extends LightningElement {
    @track quantity = 1;
    @api productId;
    @api loadingLabel = 'Loading...';
    @api outOfStockLabel = 'Out of stock';
    @api addToCartLabel = 'Add to cart';
    cartId;
    productInventory = null;
    isLoading = true;

    @wire(CartAdapter)
    wireCartAdapter({ data, error }) {
        if (data) {
            //console.log('Cart adapter data:', JSON.stringify(data, null, 2));
            if (data?.cartSummary) {
                this.cartId = data.cartSummary.cartId;
            } else {
                //console.log('cartSummary is undefined or null');
                this.cartId = null;
            }
        } else if (error) {
            console.log('Error fetching cart adapter');
        }
    }

    @wire(ProductInventoryLevelsAdapter, { productIds: '$productIds' })
    wireProductInventory({ data, error }) {
        this.isLoading = true;
        if (data) {
            //console.log('Product inventory data:', JSON.stringify(data, null, 2));
            const inventoryGroup = data.locationGroups && data.locationGroups[0];
            const inventoryProduct = inventoryGroup
                ? inventoryGroup.inventoryProducts.find(product => product.product2Id === this.productId)
                : null;
    
            if (inventoryProduct) {
                this.productInventory = inventoryProduct;
                this.isLoading = false;
            } else {
                console.error('No inventory data found for productId:', this.productId);
            }
        } else if (error) {
            console.log('Fetching product inventory');
        }
    }

    get productIds() {
        return [this.productId];
    }

    async addToCart() {
        const isAvailable = this.checkProductAvailability();
        if (!isAvailable) {
            this.template.querySelector('c-custom-toast').showToast('error', 'El producto no está disponible en stock.');
            return;
        }

        // Validar el carrito
        const result = await validateCart({ 
            cartId: this.cartId,
            productId: this.productId,
            quantityToAdd: this.quantity 
        });
        if (result) {
            this.template.querySelector('c-custom-toast').showToast('error', result);
            return;
        }
        
        await this.addItemToCart();
    }

    checkProductAvailability() {
        if (this.productInventory && this.productInventory.availableToOrder > 0) {
            return true;
        }
        return false;
    }

    async addItemToCart() {
        addItemToCart(this.productId, this.quantity)
        .then((data) => {
            if (data) {
                trackAddProductToCart(
                    this.productId
                );
            }
        })
        .catch((error) => {
            this.error = error;
            console.log("error:", error);
        })
        .finally(() => {
            this.dispatchEvent(
                new CustomEvent("cartchanged", {
                bubbles: true,
                composed: true
                })
            );
        });
    }

    get isButtonDisabled() {
        return this.isLoading || !this.checkProductAvailability();
    }

    get buttonLabel() {
        if (this.isLoading) {
            return this.loadingLabel;
        }
        if (!this.checkProductAvailability()) {
            return this.outOfStockLabel;
        }
        return this.addToCartLabel;
    }
}