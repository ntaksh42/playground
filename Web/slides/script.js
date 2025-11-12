// スライド管理クラス
class SlideShow {
    constructor() {
        this.slides = document.querySelectorAll('.slide');
        this.currentSlide = 0;
        this.totalSlides = this.slides.length;

        // DOM要素の取得
        this.prevBtn = document.querySelector('.prev-btn');
        this.nextBtn = document.querySelector('.next-btn');
        this.currentSpan = document.querySelector('.current');
        this.totalSpan = document.querySelector('.total');
        this.progressFill = document.querySelector('.progress-fill');

        this.init();
    }

    init() {
        // 初期表示の設定
        this.updateSlide();
        this.totalSpan.textContent = this.totalSlides;

        // イベントリスナーの設定
        this.prevBtn.addEventListener('click', () => this.prevSlide());
        this.nextBtn.addEventListener('click', () => this.nextSlide());

        // キーボードイベント
        document.addEventListener('keydown', (e) => this.handleKeyPress(e));

        // タッチイベント（スワイプ対応）
        this.setupTouchEvents();
    }

    updateSlide() {
        // すべてのスライドから active クラスを削除
        this.slides.forEach((slide, index) => {
            slide.classList.remove('active', 'prev');
            if (index < this.currentSlide) {
                slide.classList.add('prev');
            }
        });

        // 現在のスライドに active クラスを追加
        this.slides[this.currentSlide].classList.add('active');

        // スライド番号を更新
        this.currentSpan.textContent = this.currentSlide + 1;

        // プログレスバーを更新
        const progress = ((this.currentSlide + 1) / this.totalSlides) * 100;
        this.progressFill.style.width = progress + '%';

        // ボタンの有効/無効を切り替え
        this.prevBtn.disabled = this.currentSlide === 0;
        this.nextBtn.disabled = this.currentSlide === this.totalSlides - 1;
    }

    nextSlide() {
        if (this.currentSlide < this.totalSlides - 1) {
            this.currentSlide++;
            this.updateSlide();
        }
    }

    prevSlide() {
        if (this.currentSlide > 0) {
            this.currentSlide--;
            this.updateSlide();
        }
    }

    goToSlide(index) {
        if (index >= 0 && index < this.totalSlides) {
            this.currentSlide = index;
            this.updateSlide();
        }
    }

    handleKeyPress(e) {
        switch(e.key) {
            case 'ArrowRight':
            case 'ArrowDown':
            case ' ':
            case 'PageDown':
                e.preventDefault();
                this.nextSlide();
                break;
            case 'ArrowLeft':
            case 'ArrowUp':
            case 'PageUp':
                e.preventDefault();
                this.prevSlide();
                break;
            case 'Home':
                e.preventDefault();
                this.goToSlide(0);
                break;
            case 'End':
                e.preventDefault();
                this.goToSlide(this.totalSlides - 1);
                break;
        }
    }

    setupTouchEvents() {
        let touchStartX = 0;
        let touchEndX = 0;

        const slidesContainer = document.querySelector('.slides-container');

        slidesContainer.addEventListener('touchstart', (e) => {
            touchStartX = e.changedTouches[0].screenX;
        });

        slidesContainer.addEventListener('touchend', (e) => {
            touchEndX = e.changedTouches[0].screenX;
            this.handleSwipe();
        });

        const handleSwipe = () => {
            const swipeThreshold = 50;
            const diff = touchStartX - touchEndX;

            if (Math.abs(diff) > swipeThreshold) {
                if (diff > 0) {
                    // 左にスワイプ - 次へ
                    this.nextSlide();
                } else {
                    // 右にスワイプ - 前へ
                    this.prevSlide();
                }
            }
        };

        this.handleSwipe = handleSwipe;
    }
}

// DOMの読み込みが完了したらスライドショーを初期化
document.addEventListener('DOMContentLoaded', () => {
    new SlideShow();
});
