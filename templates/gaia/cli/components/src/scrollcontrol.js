/*
Todo:
DONE drop target selector, always use div 
*/
class ScrollControl {
    constructor( options={}){
        let defaultOptions = {
            triggerSelector: 'section',
            indicatorSelector: 'nav',
            activeClass: 'active',
            offset: 100
        }

        this.options = Object.assign({}, defaultOptions, options);
        this.indicator = document.querySelector(this.options.indicatorSelector);
        this.triggers = document.querySelectorAll(
                           this.options.triggerSelector);
    }

    onScroll() {
        const trigger = this.getCurrentTrigger();
        const indicator = this.getCurrentIndicator(trigger);

        if (indicator) {
            this.removeActive();
            this.setActive(indicator);
        }
    }

    getCurrentTrigger() {
        for (let i = 0; i < this.triggers.length; i++) {
            const triggerEl = this.triggers[i];
            const startAt = triggerEl.offsetTop;
            const endAt = startAt + triggerEl.offsetHeight;
            const currentPosition =
                (document.documentElement.scrollTop ||
                    document.body.scrollTop) + this.options.offset;
            const isInView =
                currentPosition >= startAt && currentPosition < endAt;
            if (isInView) {
                return triggerEl;
            }
        }
    }

    // section -> menuItem    Semantics
    // trigger -> indicatior  Semi-semantics (abstract semantics)
    getCurrentIndicator(triggerEl) {
        const triggerId = triggerEl.getAttribute('id');
        return this.indicator.querySelector(`[data-target=${triggerId}]`);
    }

    setActive(indicatorEl) {
        const isActive = 
            indicatorEl.classList.contains(this.options.activeClass);
        if (!isActive) {
            indicatorEl.classList.add(this.options.activeClass);
        }
    }

    removeActive() {
        const indicators = this.indicator.querySelectorAll("div");
        indicators.forEach((indicator) => {
                indicator.classList.remove(this.options.activeClass);
        });
    }
}
